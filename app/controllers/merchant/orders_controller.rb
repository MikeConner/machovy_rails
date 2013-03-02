class Merchant::OrdersController < Merchant::BaseController
  load_and_authorize_resource

  before_filter :authenticate_user!
  before_filter :sanitize_shipping_info, :only => [:create]
  
  # GET /orders/1
  def show
    @order = Order.find(params[:id])
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # Warning: similar code in gift_certificates_controller
  def create
    # We get charged for all Gateway requests, so make sure everything else is good before submitting
    # We have already validated the card through Ajax in order to get here, but the Order object might
    #   fail even with a valid card (e.g., a shipping address is required for a product promotion and it's missing)
    #   Don't want to charge the card successfully and then fail to save the order!
    # So before we do anything with the card, ensure the Order is good
    # Need to have a transaction_id to validate, so just give it a dummy one -- reset to the real one later
    @order.transaction_id = '0'
    charge_success = false
    
    if @order.valid? and validate_quantity?(@order)
      total_charge = @order.total_cost - @order.user.total_macho_bucks
      if total_charge > 0
        # We need to generate the card again anyway, so let's validate that as well, even though Ajax already did it
        #   I suppose people could be doing weird things with browsers that could cause this to change after the Ajax call
        @card = ActiveMerchant::Billing::MachovySecureNetGateway.instance.parse_card(params)
        if @card.valid?
          @billing_address = ActiveMerchant::Billing::MachovySecureNetGateway.instance.parse_address(params)
          
          gateway_response = charge_card(@order, @card, @billing_address, total_charge)
          charge_success = gateway_response.success?
          
          if charge_success
            # Set transaction_id to the correct value
            @order.transaction_id = gateway_response.authorization
            # Transfer name from card
            @order.first_name = @card.first_name
            @order.last_name = @card.last_name
          else
            @order.errors.add :base, "Credit Processing Error: #{gateway_response.message}"
            # Defensive programming; make the order object invalid so that it can't be saved
            # We should not be saving it if charge_success is false
            @order.transaction_id = nil
            
            logger.error gateway_response.message
            
            puts gateway_response.message
            puts gateway_response.inspect
          end
        else
          # Pathological case
          @order.errors.add :base, ActiveMerchant::Billing::MachovySecureNetGateway.instance.generate_card_error_msg(@card)
        end
      else
        # No charge necessary
        charge_success = true
        # Validated, so it has to be there
        @order.transaction_id = Order::MACHO_BUCKS_TRANSACTION_ID
      end
      
      if charge_success
        # This has to be valid here, or it's a programming error and should fail badly
        @order.save!
        # After saving the order, create the associated vouchers using the promotion strategy
        # status defaults to Available; uuid is created upon save
        if @order.promotion.strategy.generate_vouchers(@order)
          flash[:notice] = I18n.t('order_successful')
          
          # If everything worked (voucher(s) saved), send the email
          # Products are handled differently in the mailer
          UserMailer.delay.promotion_order_email(@order)
          @order.user.log_activity(@order)
          
          # Debit the Macho Bucks. Usually 0, but possible they had more bucks than it cost
          # In the pathological case where they have negative macho bucks, the card was charged extra. That has to be cleared as well.
          #   So we have to check for != 0, not > 0
          if @order.user.total_macho_bucks != 0
            deduction = @order.user.total_macho_bucks < 0 ? @order.user.total_macho_bucks :  [@order.user.total_macho_bucks, @order.total_cost].min
            bucks = @order.build_macho_buck(:user_id => @order.user.id, :amount => -deduction, :notes => "Credited on order: #{@order.description}")
            if !bucks.save
              flash[:alert] = 'Unable to apply macho bucks!'
            end
            UserMailer.delay.macho_bucks_order_email(bucks)
          end
          
          redirect_to merchant_order_path(@order) and return
        end
      end
    end
 
    @promotion = @order.promotion
    render 'promotions/order'
    
    # Should never get here, put theoretically possible if orders don't validate somehow; avoid template error
    #render 'new'      
    
    rescue Exception => error
      logger.error "Credit card processing error: #{error.message}"
      @order.errors.add :base, "There was a problem with your credit card. #{error.message}"
      @promotion = @order.promotion
      render 'promotions/order'
  end
  
  #TODO remove old stripe code when Vault ready
  # POST /orders
  def create_stripe
    # Order created by promotions#order and passed to merchant/orders/order_form
    # Cases: 1) not a customer; saving card
    #        2) not a customer; not saving card
    #        3) customer; using saved card
    #        4) customer; using new card and saving it
    #        5) customer; using new card and not saving it
    #
    # NOTE: I'm saving the associated user object in the orders controller, instead of trying to do it in the User model
    #       I think it makes more sense to isolate all the Stripe stuff here, than have it scattered through models.
    #       I also removed Stripe code from the Order model. It is all in the controller and User model (where it belongs).

    @stripe_customer = @order.user.stripe_customer_obj

    # Calculate total charge, adjusting for macho bucks. Do we need to charge the card?
    total_charge = @order.total_cost - @order.user.total_macho_bucks
    if total_charge > 0
      # We need to charge the credit card      
      if @stripe_customer.nil?
        charge_success = false
        
        if params[:save_card] == 'true'
          # case 1
          @stripe_customer = Stripe::Customer.create(:email => @order.email,
                                                     :description => @order.description,
                                                     :card => @order.stripe_card_token)
          
          # Not in attr_accessible for security; must assign explicitly
          @order.user.stripe_id = @stripe_customer.id
          if @order.user.save
            charge_success = charge_customer(@order, @stripe_customer, total_charge)
          else
            flash[:notice] = "Card could not be saved."
            charge_success = charge_card(@order, total_charge)
          end
        else 
          # case 2
          charge_success = charge_card(@order, total_charge)
        end
      else
        # get existing customer
        if params[:new_card] == 'true'
          if params[:save_card] == 'true'
            # case 4
            # Update the card information for an existing customer
            @stripe_customer.card = @order.stripe_card_token
            @stripe_customer.save
            
            charge_success = charge_customer(@order, @stripe_customer, total_charge)
          else
            # case 5
             charge_success = charge_card(@order, total_charge)
          end
        else
          # case 3
          charge_success = charge_customer(@order, @stripe_customer, total_charge)
        end
      end
    else
      # No charge necessary
      charge_success = true
      # Validated, so it has to be there
      @order.transaction_id = Order::MACHO_BUCKS_TRANSACTION_ID
    end
    
    # Charge operation should either succeed or throw an exception
    if charge_success
      # If the charge was successful, order will have charge_id (validated on save)
      if @order.save
        # After saving the order, create the associated vouchers using the promotion strategy
        # status defaults to Available; uuid is created upon save
        if @order.promotion.strategy.generate_vouchers(@order)
          flash[:notice] = I18n.t('order_successful')
          
          # If everything worked (voucher(s) saved), send the email
          # Products are handled differently in the mailer
          UserMailer.delay.promotion_order_email(@order)
          @order.user.log_activity(@order)
          
          # Debit the Macho Bucks. Usually 0, but possible they had more bucks than it cost
          # In the pathological case where they have negative macho bucks, the card was charged extra. That has to be cleared as well.
          #   So we have to check for != 0, not > 0
          if @order.user.total_macho_bucks != 0
            deduction = @order.user.total_macho_bucks < 0 ? @order.user.total_macho_bucks :  [@order.user.total_macho_bucks, @order.total_cost].min
            bucks = @order.build_macho_buck(:user_id => @order.user.id, :amount => -deduction, :notes => "Credited on order: #{@order.description}")
            if !bucks.save
              flash[:alert] = 'Unable to apply macho bucks!'
            end
            UserMailer.delay.macho_bucks_order_email(bucks)
          end
          
          redirect_to merchant_order_path(@order) and return
        end
      else
        @order.errors.add :base, "Could not save order."
      end
    end

    # Should never get here, put theoretically possible if orders don't validate somehow; avoid template error
    render 'new'      
  
    # Don't need a begin inside a def
    rescue Stripe::InvalidRequestError => error
      logger.error "Stripe error while creating customer: #{error.message}"
      @order.errors.add :base, "There was a problem with your credit card. #{error.message}"
      @promotion = @order.promotion
      render 'promotions/order'
      
    rescue Stripe::CardError => error
      logger.error "Stripe error: #{error.message}"
      @order.errors.add :base, "There was a problem with your credit card. #{error.message}"
      @promotion = @order.promotion
      render 'promotions/order'
  end
  
  # DELETE /orders/1
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    redirect_to root_path
  end

private
  # On some browsers, I suspect it's pre-filling in City/State/Zipcode to non-visible shipping address fields, or it's sending non-blank values
  # The result is they get a "state/zipcode invalid" error on ordering, even though the shipping address is not required. Avoid this by deleting
  # the shipping address keys if the shipping address is not required
  def sanitize_shipping_info
    params[:order].except!(:city, :state, :zipcode) if !@order.shipping_address_required?
  end
  
  def charge_card(order, card, address, total_charge)
    # Ensure billing address has the email
    address[:email] = current_user.email
    
    ActiveMerchant::Billing::MachovySecureNetGateway.instance.purchase((total_charge * 100).round, 
                                                                        card, 
                                                                        :order_id => Utilities::generate_order, # order not saved yet
                                                                        :shipping_required => order.shipping_address_required?, 
                                                                        :billing_address => address,
                                                                        :customer_ip => current_user.current_sign_in_ip)
  end
  
  def validate_quantity?(order)
    min_quantity = order.promotion.min_per_customer

    if order.promotion.unlimited?(current_user)
      if order.quantity < min_quantity
        order.errors.add :base, "Quantity (#{order.quantity}) must be at least #{min_quantity}"
        return false
      end
    else
      max_quantity = order.promotion.max_quantity_for_buyer(current_user)
      if order.quantity < min_quantity or order.quantity > max_quantity
        order.errors.add :base, "Quantity (#{order.quantity}) must be between #{min_quantity} and #{max_quantity}"
        return false
      end
    end
    
    true
  end
  #TODO remove old stripe code when Vault ready
=begin
  def charge_card(order, total_charge)
    charge = Stripe::Charge.create(description: order.description, 
                                   card: order.stripe_card_token, 
                                   amount: (total_charge * 100).round,
                                   currency: 'usd')
    order.charge_id = charge.id
    true
  end
  
  def charge_customer(order, customer, total_charge)
    charge = Stripe::Charge.create(description: order.description, 
                                   customer: customer.id, 
                                   amount: (total_charge * 100).round,
                                   currency: 'usd')
    order.charge_id = charge.id
    true
  end
=end
end
