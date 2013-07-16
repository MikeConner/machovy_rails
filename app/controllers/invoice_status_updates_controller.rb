class InvoiceStatusUpdatesController < ApplicationController
  # These come in from the Bitcoin gateway with a key and a status
  def create
    invoice = BitcoinInvoice.find_by_notification_key(params[:key])
    if !invoice.nil?
      invoice.invoice_status_updates.create!(:status => params[:invoice_status_update][:status])
      
      @order = invoice.order
      # High speed: New -> Complete
      # Medium speed: New -> Paid -> Confirmed -> Complete
      # Low speed: New -> Paid -> Complete
      # Or New -> Expired
      # Or New -> Paid -> Invalid (-> Confirmed -> Complete)
      case invoice.invoice_status
      # Trigger on first of CONFIRMED/COMPLETE (@order.vouchers.empty? checks to see if it's already been sent)
      when InvoiceStatusUpdate::CONFIRMED, InvoiceStatusUpdate::COMPLETE
        # Logic duplicated in OrdersController
        if @order.vouchers.empty? and @order.promotion.strategy.generate_vouchers(@order)
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
        end
      when InvoiceStatusUpdate::EXPIRED
        UserMailer.delay.bitcoin_order_expired_email(@order)
        @order.user.log_activity(@order.bitcoin_invoice)
      when InvoiceStatusUpdate::INVALID
        UserMailer.delay.bitcoin_order_invalid_email(@order)
        @order.user.log_activity(@order.bitcoin_invoice)
      end
    end
    
    render :nothing => true
    
  rescue => err
    puts err.inspect
  end
end