class Merchant::OrdersController < Merchant::BaseController
  load_and_authorize_resource

  before_filter :authenticate_user!

  # GET /orders/1
  def show
    @order = Order.find(params[:id])
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # POST /orders
  def create
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
      @order.charge_id = "Macho Bucks"
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
end
