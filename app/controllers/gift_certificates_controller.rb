class GiftCertificatesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_admin, :only => [:index]
  before_filter :transform_email, :only => [:create]
  
  load_and_authorize_resource
  
  def new
    @certificate = current_user.gift_certificates.build(:amount => GiftCertificate::DEFAULT_AMOUNT)
    #TODO Replace stripe with vault
    @stripe_customer = nil; #current_user.stripe_customer_obj
  end
  
  # Warning: similar code in orders_controller
  def create
    @certificate = GiftCertificate.new(params[:gift_certificate])
    @certificate.transaction_id = '0'
    # Special case; it will reinitialize amount to $25 if blank because of the default.
    if params[:gift_certificate][:amount].empty?
      @certificate.amount = nil
    end
    charge_success = false
    
    if @certificate.valid?
      # We need to generate the card again anyway, so let's validate that as well, even though Ajax already did it
      #   I suppose people could be doing weird things with browsers that could cause this to change after the Ajax call
      @card = ActiveMerchant::Billing::MachovySecureNetGateway.instance.parse_card(params)
      if @card.valid?
        @billing_address = ActiveMerchant::Billing::MachovySecureNetGateway.instance.parse_address(params)
        
        gateway_response = charge_card(@order, @card, @billing_address, @certificate.amount)
        charge_success = gateway_response.success?
        
        if charge_success
          # Set transaction_id to the correct value
          @certificate.transaction_id = gateway_response.authorization
          # Transfer name from card
          @certificate.first_name = @card.first_name
          @certificate.last_name = @card.last_name
        else
          @certificate.errors.add :base, "Credit Processing Error: #{gateway_response.message}"
          # Defensive programming; make the order object invalid so that it can't be saved
          # We should not be saving it if charge_success is false
          @certificate.transaction_id = nil
          
          logger.error gateway_response.message
          
          puts gateway_response.message
          puts gateway_response.inspect
        end
      else
        # Pathological case
        @certificate.errors.add :base, ActiveMerchant::Billing::MachovySecureNetGateway.instance.generate_card_error_msg(@card)
      end
      
      if charge_success
        # Now determine if the recipient is a valid user or not. Must be confirmed!
        @certificate_user = User.find_by_email(@certificate.email)
        if @certificate_user.nil? or !@certificate_user.confirmation_token.nil?
          # Not a valid user -- need to save the certificate
          # If the charge was successful, recipient will have charge_id (validated on save)
          @certificate.save!
          
          # Receipt for macho bucks given to a recipient who hasn't yet signed up
          UserMailer.delay.gift_given_email(@certificate)
          # Mail to recipient saying they've got pending macho bucks, with a signup link
          UserMailer.delay.gift_received_email(@certificate)
            
          redirect_to about_macho_bucks_path, :notice => "Thank you for buying a gift certificate! #{@certificate.email}'s account will be credited on signup." and return
        else
          # A valid user -- apply the macho bucks
          ActiveRecord::Base.transaction do
            @certificate_user.macho_bucks.create!(:amount => @certificate.amount, :notes => "Gift certificate bought by #{@certificate.user.email}")
            
            # Receipt for macho bucks given to a current user who's been immediately credited
            UserMailer.delay.gift_given_user_email(@certificate)
            # Mail to recipient saying they received macho bucks and can login to redeem them
            UserMailer.delay.gift_credited_email(@certificate)
            @certificate.pending = false
            @certificate.save!
          end
             
          redirect_to about_macho_bucks_path, :notice => "Thank you for buying a gift certificate! #{@certificate.email}'s account has been credited." and return
        end               
      end  
    end

    render 'new'
  end
  
  #TODO Replace stripe with vault
  def create_stripe
    # Need to set these so that they don't defeat the validation; update later
    params[:gift_certificate][:charge_id] = 'temp'
    @certificate = GiftCertificate.new(params[:gift_certificate])
    @stripe_customer = @certificate.user.stripe_customer_obj
    
    # Special case; it will reinitialize amount to $25 if blank because of the default.
    if params[:gift_certificate][:amount].empty?
      @certificate.amount = nil
    end
    # Is it initially valid? Don't try to charge the card until the email and amount is valid
    # Don't both with saving the card when buying macho bucks -- simplifies it
    # Offer to use any stored card, though; that doesn't cost anything
    if @certificate.valid?
      # Now try to charge the card
      if @stripe_customer.nil?
        # case 2
        charge_success = charge_card(@certificate, params[:order_stripe_card_token])
      else
        # get existing customer
        if params[:new_card] == 'true'
          # case 5
          charge_success = charge_card(@certificate, params[:order_stripe_card_token])
        else
          # case 3
          charge_success = charge_customer(@certificate, @stripe_customer)
        end
      end
      
      # Charge operation should either succeed or throw an exception
      if charge_success
        # Now determine if the recipient is a valid user or not. Must be confirmed!
        @certificate_user = User.find_by_email(@certificate.email)
        if @certificate_user.nil? or !@certificate_user.confirmation_token.nil?
          # Not a valid user -- need to save the certificate
          # If the charge was successful, recipient will have charge_id (validated on save)
          @certificate.save!
          
          # Receipt for macho bucks given to a recipient who hasn't yet signed up
          UserMailer.delay.gift_given_email(@certificate)
          # Mail to recipient saying they've got pending macho bucks, with a signup link
          UserMailer.delay.gift_received_email(@certificate)
            
          redirect_to about_macho_bucks_path, :notice => "Thank you for buying a gift certificate! #{@certificate.email}'s account will be credited on signup." and return
        else
          # A valid user -- apply the macho bucks
          ActiveRecord::Base.transaction do
            @certificate_user.macho_bucks.create!(:amount => @certificate.amount, :notes => "Gift certificate bought by #{@certificate.user.email}")
            
            # Receipt for macho bucks given to a current user who's been immediately credited
            UserMailer.delay.gift_given_user_email(@certificate)
            # Mail to recipient saying they received macho bucks and can login to redeem them
            UserMailer.delay.gift_credited_email(@certificate)
            @certificate.pending = false
            @certificate.save!
          end
             
          redirect_to about_macho_bucks_path, :notice => "Thank you for buying a gift certificate! #{@certificate.email}'s account has been credited." and return
        end        
      end
      
      # Should never get here; theoretically possible if we failed to save the certificate
      render 'new'
    else
      # "Normal" error case
      render 'new'
    end
  end
  
  def index
    @pending = GiftCertificate.pending
    @redeemed = GiftCertificate.redeemed
    
    render :layout => 'layouts/admin'
  end
  
  def edit
    @certificate = GiftCertificate.find(params[:id])
  end
  
  def update
    @certificate = GiftCertificate.find(params[:id])
    old_email = @certificate.email
    if @certificate.update_attributes(params[:gift_certificate])
      # The email has changed. Is the new email a current user?
      @certificate_user = User.find_by_email(@certificate.email)
      if @certificate_user.nil? or !@certificate_user.confirmation_token.nil?
        # Not a valid user   
        # Send email saying recipient of a pending gift certificate has been changed
        UserMailer.delay.gift_update_email(@certificate, old_email)
        
        msg = "#{@certificate.email}'s account will be credited on signup."
      else
        # A valid user -- just apply the macho bucks and discard the recipient
        ActiveRecord::Base.transaction do
          @certificate_user.macho_bucks.create!(:amount => @certificate.amount, :notes => "Gift certificate bought by #{@certificate.user.email}")
          @certificate.pending = false
          @certificate.save!
          
          # Receipt for macho bucks given to a current user who's been immediately credited
          UserMailer.delay.gift_given_user_email(@certificate)
          # Mail to recipient saying they received macho bucks and can login to redeem them
          UserMailer.delay.gift_credited_email(@certificate)
        end
         
        msg = "#{@certificate.email}'s account has been credited."         
      end        
      
      redirect_to merchant_vouchers_path, :notice => "Gift Certificate recipient email successfully updated. #{msg}"
    else
      render 'edit'
    end    
  end
  
private  
  def transform_email
    params[:gift_certificate][:email] = params[:gift_certificate][:email].downcase.strip
  end
  
  def ensure_admin
    if !current_user.has_role?(Role::SUPER_ADMIN)
      redirect_to root_path, :alert => I18n.t('admins_only')
    end
  end

  def charge_card(order, card, address, total_charge)
    # Ensure billing address has the email
    address[:email] = current_user.email
    puts address.inspect
    
    ActiveMerchant::Billing::MachovySecureNetGateway.instance.purchase((total_charge * 100).round, 
                                                                        card, 
                                                                        :order_id => Utilities::generate_order, # order not saved yet
                                                                        :shipping_required => false, 
                                                                        :billing_address => address,
                                                                        :customer_ip => current_user.current_sign_in_ip)
  end
  
  #TODO Replace stripe with vault  
=begin  
  def charge_card(certificate, token)
    charge = Stripe::Charge.create(description: "#{certificate.user.email} buying for #{certificate.email}", 
                                   card: token, 
                                   amount: (certificate.amount * 100).round,
                                   currency: 'usd')
    certificate.charge_id = charge.id
    true
  end
  
  def charge_customer(certificate, customer)
    charge = Stripe::Charge.create(description: "#{certificate.user.email} buying for #{certificate.email}",
                                   customer: customer.id, 
                                   amount: (certificate.amount * 100).round,
                                   currency: 'usd')
    certificate.charge_id = charge.id
    true
  end
=end
end
