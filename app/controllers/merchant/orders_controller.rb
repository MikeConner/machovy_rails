class Merchant::OrdersController < Merchant::BaseController
  load_and_authorize_resource

  before_filter :authenticate_user!
  # GET /orders
  # GET /orders.json
  def index
    @useremailaddy = current_user.email
    @orders = Order.all


    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orders }
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    puts "Orders/show"
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.json
  def new
    @order = Order.new


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order }
    end
  end

  def badPayment
    @order = Order.new


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order }
    end
  end


  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(params[:order])
    @categories = Category.all

#    respond_to do |format|
#      if @order.save
#        format.html { redirect_to @order, notice: 'Order was successfully created.' }
#        format.json { render json: @order, status: :created, location: @order }
#      else
#        format.html { render action: "new" }
#        format.json { render json: @order.errors, status: :unprocessable_entity }
#      end
#    end



    if @order.save_with_payment
      just_purchased = Voucher.new(:order => @order, :issue_date => Time.now)
      #just_purchased.populate_from(@order)
      if just_purchased.save
        #  create new voucher
        # send email to person
        # render voucher in order afterwards
        redirect_to merchant_order_path(@order)
      else
        # Maybe a different view?
        render 'badPayment'
      end
    else
      render 'badPayment'
    end



  end

  # PUT /orders/1
  # PUT /orders/1.json
  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(params[:order])
        format.html { redirect_to [:merchant, @order], notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order = Order.find(params[:id])
    @order.destroy


    respond_to do |format|
      format.html { redirect_to merchant_orders_url }
      format.json { head :no_content }
    end
  end
end
