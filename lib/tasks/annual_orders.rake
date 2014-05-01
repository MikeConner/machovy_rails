require 'csv'

namespace :db do
  desc "Print annual orders"
  task :annual_orders => :environment do
    CSV.open('orders-2013.csv', 'w' ) do |writer|
      writer << ["Date", "Order ID", "Name", "Amount", "Machovy Share", "Escrowed", "Status", "Ref ID"]
      
      Order.where("(created_at >= '1/1/2013') AND (created_at < '1/1/2014')").each do |order|
        # Skip orders without vouchers
        next if order.transaction_id == Order::MACHO_BUCKS_TRANSACTION_ID
        
        escrowed = 0
        share = order.machovy_share
       
        if order.vouchers.empty?
          status = "Immediate"
         else
          status = order.vouchers.first.status
          if Voucher::REDEEMED != status
            share = 0
            escrowed = order.machovy_share
          end
        end
        
        writer << [order.created_at.try(:strftime, ApplicationHelper::DATE_FORMAT), order.id, order.promotion.title, order.total_cost, share, escrowed, status, order.transaction_id]
      end
    end
  end
end
