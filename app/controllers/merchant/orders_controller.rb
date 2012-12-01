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
          charge_success = charge_customer(@order, @stripe_customer)
        else
          flash[:notice] = "Card could not be saved."
          charge_success = charge_card(@order)
        end
      else 
        # case 2
        charge_success = charge_card(@order)
      end
    else
      # get existing customer
      if params[:new_card] == 'true'
        if params[:save_card] == 'true'
          # case 4
          # Update the card information for an existing customer
          @stripe_customer.card = @order.stripe_card_token
          @stripe_customer.save
          
          charge_success = charge_customer(@order, @stripe_customer)
        else
          # case 5
           charge_success = charge_card(@order)
        end
      else
        # case 3
        charge_success = charge_customer(@order, @stripe_customer)
      end
    end

    # Charge operation should either succeed or throw an exception
    if charge_success
      # If the charge was successful, order will have charge_id (validated on save)
      if @order.save
        # After saving the order, create the associated vouchers using the promotion strategy
        # status defaults to Available; uuid is created upon save
        if @order.promotion.strategy.generate_vouchers(@order)
          flash[:notice] = I18n.t('order_successful')
          
          # If everything worked (voucher saved), send the email
          UserMailer.promotion_order_email(@order).deliver
          @order.user.log_activity(@order)
          
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
      @order.errors.add :base, "There was a problem with your credit card. #{error_message}"
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

  # The following actions are unused/left over from scaffolding  
=begin
  # GET /orders
  def index
    @Orders = Order.all
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
  end
  
  # PUT /orders/1
  def update
    @order = Order.find(params[:id])
    if @order.update_attributes(params[:order])
      redirect_to [:merchant, @order], notice: 'Order was successfully updated.'
    else
      render 'edit'
    end
  end  
=end
  
private
  def charge_card(order)
    # total_cost(true) returns it in pennies
    charge = Stripe::Charge.create(description: order.description, 
                                   card: order.stripe_card_token, 
                                   amount: order.total_cost(true),
                                   currency: 'usd')
    order.charge_id = charge.id
    true
  end
  
  def charge_customer(order, customer)
    charge = Stripe::Charge.create(description: order.description, 
                                   customer: customer.id, 
                                   amount: order.total_cost(true),
                                   currency: 'usd')
    order.charge_id = charge.id
    true
  end
end
