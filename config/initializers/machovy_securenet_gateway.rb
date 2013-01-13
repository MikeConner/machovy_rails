module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class MachovySecureNetGateway < Gateway

      DEVELOPER_ID = '10000148'      
      API_VERSION = '4.1.4'
      TRANSACTION_ID_LEN = 15

      # No Magic Numbers!
      # OVERRIDE_FROM
      BILLING_INFO_FROM_TRANSACTION = 0
      # IndustrySpecificData
      PHYSICAL_GOODS = 'P'
      DIGITAL_GOODS = 'D'
      # TransactionService
      REGULAR_TRANSACTION = 0
      VAULT_CUSTOMER_ID = 1
      VAULT_SECONDARY_KEY = 2
      VAULT_ADD_CUSTOMER = 3
      # DCI
      NO_DUPLICATE_CHECKING = 0
      
      TRANSACTIONS = {
        :auth_only                      => "0000",  #
        :partial_auth_only              => "0001",
        :auth_capture                   => "0100",  #
        :partial_auth_capture           => "0101",
        :prior_auth_capture             => "0200",
        :capture_only                   => "0300",  #
        :void                           => "0400",  #
        :partial_void                   => "0401",
        :credit                         => "0500",  #
        :credit_authonly                => "0501",
        :credit_priorauthcapture        => "0502",
        :force_credit                   => "0600",
        :force_credit_authonly          => "0601",
        :force_credit_priorauthcapture  => "0602",
        :verification                   => "0700",
        :auth_increment                 => "0800",
        :issue                          => "0900",
        :activate                       => "0901",
        :redeem                         => "0902",
        :redeem_partial                 => "0903",
        :deactivate                     => "0904",
        :reactivate                     => "0905",
        :inquiry_balance                => "0906"
      }

      XML_ATTRIBUTES = { 'xmlns' => "http://gateway.securenet.com/API/Contracts",
                         'xmlns:i' => "http://www.w3.org/2001/XMLSchema-instance"
                       }
                             
      self.supported_countries = ['US']
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]
      self.homepage_url = 'http://www.securenet.com/'
      self.display_name = 'SecureNet'

      self.test_url = 'https://certify.securenet.com/API/gateway.svc/webHttp/'     
      self.live_url = 'https://gateway.securenet.com/api/Gateway.svc/webHttp/'
      
      APPROVED, DECLINED, ERROR = 1, 2, 3

      RESPONSE_CODE, RESPONSE_REASON_CODE, RESPONSE_REASON_TEXT = 0, 2, 3
      AVS_RESULT_CODE, CARD_CODE_RESPONSE_CODE, TRANSACTION_ID  = 5, 6, 8

      CARD_CODE_ERRORS = %w( N S )
      AVS_ERRORS = %w( A E N R W Z )

      def initialize(options = {})
        requires!(options, :login, :password)
        super
      end

      # Access as a singleton
      @@instance = nil
      
      def self.instance
        if @@instance.nil?
          @@instance = ActiveMerchant::Billing::MachovySecureNetGateway.new(:login => SECURENET_ID, :password => SECURENET_KEY)
        end
        
        return @@instance
      end
      
      def authorize(money, creditcard, options = {})
        commit(build_credit_card_sale_params(creditcard, options, :auth_only), money)
      end

      def purchase(money, creditcard, options = {})
        commit(build_credit_card_sale_params(creditcard, options, :auth_capture), money)
      end

      def capture(money, creditcard, authorization, options = {})
        commit(build_credit_card_sale_params_with_authorization(authorization, creditcard, options, :prior_auth_capture), money)
      end

      def credit(money, creditcard, authorization, options = {})
        commit(build_credit_card_sale_params_with_authorization(authorization, creditcard, options, :credit), money)
      end

      def void(money, creditcard, authorization, options = {})
        commit(build_credit_card_sale_params_with_authorization(authorization, creditcard, options, :void), money)
      end

      # ECheck transactions
      def echeck_purchase(money, options = {})
        commit(build_echeck_sale_params(options, :auth_capture), money)
      end
      
      def echeck_void(money, authorization, options = {})
        commit(build_echeck_sale_params_with_authorization(authorization, options, :void), money)
      end

      def echeck_credit(money, authorization, options = {})
        commit(build_echeck_sale_params_with_authorization(authorization, options, :credit), money)
      end

      # Required for settling transactions before issuing credits
      def close_batch
        xml = build_batch_xml
        #puts xml
        post_xml(xml, true)
      end
      
      # Utilities for creating credit card objects from parameters, and generating text error messages
      def parse_card(params)
        ActiveMerchant::Billing::CreditCard.new(:number => params[:card_number],
                                                :verification_value => params[:card_code],
                                                :month => params[:card_month], 
                                                :year => params[:card_year], 
                                                :first_name => params[:first_name],
                                                :last_name => params[:last_name])     
      end

      def parse_address(params)
        address = Hash.new
        
        address[:city] = params[:city] if params.has_key?(:city)
        address[:state] = params[:state] if params.has_key?(:state)
        address[:zip] = params[:zipcode] if params.has_key?(:zipcode)
        
        address
      end
           
      # Convert errors into a single string
      # Note that an invalid credit card will generate "invalid number" if it's *close*, 
      #   and "brand is required" if it's so far off it can't determine the CC type
      def generate_card_error_msg(card)
        if card.valid?
          ''
        else
          error_message = ''
          
          # Key -> [error array]
          card.errors.each do |key, errors|
            if !errors.empty?
              errors.each do |error|
                if !error_message.blank?
                  error_message += '; '
                end
                
                error_message += "#{key} #{error}"
              end
            end
          end
          
          error_message
        end
      end  
          
    private
      def commit(params, money)
        post_xml(build_transaction_xml(params, money))
      end
      
      def post_xml(xml, batch = false)
        #puts "Posting to #{self.test_url}"
        #puts "With #{SECURENET_ID}, #{SECURENET_KEY}"
        target_url = test? ? self.test_url : self.live_url
        target_url += batch ? "CloseBatch" : "ProcessTransaction"
        #puts target_url
        #puts xml
        # Some kind of timing issue here! Need to wait for it to settle the transaction!
        if batch
          sleep 1
        end
        
        data = ssl_post(target_url, xml, "Content-Type" => "text/xml")
        response = parse(data)
        #puts "Raw response: " + response.inspect
        
        Response.new(success?(response), message_from(response), response,
          :test => test?,
          :authorization => response[:transactionid],
          :avs_result => { :code => response[:avs_result_code] },
          :cvv_result => response[:card_code_response_code]
        )                
        #puts "XXX: #{r.authorization}"
        #r
      end

      def build_echeck_sale_params(options, action)
        params = Hash.new
        
        add_common_fields('ECHECK', params, options, action)
        params[:check] = { :routing_number => options[:routing_number],
                           :account_number => options[:account_number],
                           :bank_name => options[:bank_name],
                           :account_holder => "#{options[:first_name]} #{options[:last_name]}",
                           :account_type => 'CHECKING',
                           :sec_code => 'PPD' }
        # Add name, billing address, email
        add_address(params, options)

        params
      end

      def build_echeck_sale_params_with_authorization(authorization, options, action)
        params = build_echeck_sale_params(options, action)
        
        params[:ref_transaction_id] = authorization if !authorization.nil?

        params        
      end
      
      def build_credit_card_sale_params(creditcard, options, action)
        params = Hash.new
        
        add_common_fields('CC', params, options, action)
        # Add Card #, CVV, and Expiration Date
        add_credit_card(params, creditcard)

        # Add name, billing address, email
        add_address(params, options, creditcard)

        params
      end

      def build_credit_card_sale_params_with_authorization(authorization, creditcard, options, action)
        params = build_credit_card_sale_params(creditcard, options, action)
        
        params[:ref_transaction_id] = authorization if !authorization.nil?

        params        
      end

      #########################################################################
      # FUNCTIONS RELATED TO BUILDING THE PARAMETERS
      #########################################################################
      def add_common_fields(method, params, options, action)
        # Merchant ID and KEY
        add_merchant_key(params)
        
        # Type of transaction
        params[:code] = TRANSACTIONS[action]
        # Regular transaction (i.e., not recurring)
        params[:transaction_service] = REGULAR_TRANSACTION
        # No duplicate checking will be done, except for ORDERID
        params[:dci] = NO_DUPLICATE_CHECKING
        # Credit card transaction
        params[:method] = method
        # Billing info comes from the transaction request (vs. the Vault)
        params[:override_from] = BILLING_INFO_FROM_TRANSACTION
        # Physical vs. Digital goods
        params[:industry_specific_data] = options[:shipping_required] ? PHYSICAL_GOODS : DIGITAL_GOODS
        # Ensure there is some kind of order id
        params[:order_id] = options.has_key?(:order_id) ? options[:order_id].to_s : SecureRandom.hex(10)
        # Test flag; if production, retrieve from environment
        # In Test environment (or development), set to FALSE so that transactions settle (otherwise it will fail certification)
        if test?
          params[:test] = options.has_key?(:certification_test) ? 'FALSE' : 'TRUE'
        else
          params[:test] = SECURENET_TEST_MODE
        end  
              
        # Add ip (or customer id if vault)
        add_customer_data(params, options)
      end

      def add_credit_card(params, creditcard)
        params[:card] = { :card_code => creditcard.verification_value,
                          :card_number => creditcard.number,
                          :expiration_date => expdate(creditcard) }
      end
      
      def expdate(creditcard)
        year  = sprintf("%.4i", creditcard.year)
        month = sprintf("%.2i", creditcard.month)

        "#{month}#{year[-2..-1]}"
      end

      def add_customer_data(params, options)
        if options.has_key? :customer_id
          params[:customer_id] = options[:customer_id]
        end

        if options.has_key? :customer_ip
          params[:customer_ip] = options[:customer_ip]
        end
      end

      def add_address(params, options, creditcard = nil)
        if creditcard.nil?
          params[:billing_address] = { :first_name => options[:first_name],
                                       :last_name => options[:last_name] }
        else
          params[:billing_address] = { :first_name => creditcard.first_name,
                                       :last_name => creditcard.last_name }
        end
        
        if address = options[:billing_address]          
          params[:billing_address][:email] = address[:email] if address.has_key? :email
          params[:billing_address][:address1] = address[:address1] if address.has_key?(:address1)
          params[:billing_address][:city] = address[:city] if address.has_key?(:city)
          params[:billing_address][:company] = address[:company] if address.has_key?(:company)
          params[:billing_address][:country] = address[:country] if address.has_key?(:country)
          params[:billing_address][:phone] = address[:phone] if address.has_key?(:phone)
          params[:billing_address][:state] = address[:state] if address.has_key?(:state)
          params[:billing_address][:zip] = address[:zip] if address.has_key?(:zip)
        end

        if address = options[:shipping_address]
          params[:shipping_address] = Hash.new
          params[:shipping_address][:first_name] = address[:first_name] if address.has_key?(:first_name)
          params[:shipping_address][:last_name] = address[:last_name] if address.has_key?(:last_name)
          params[:shipping_address][:address1] = address[:address1] if address.has_key?(:address1)
          params[:shipping_address][:city] = address[:city] if address.has_key?(:city)
          params[:shipping_address][:company] = address[:company] if address.has_key?(:company)
          params[:shipping_address][:country] = address[:country] if address.has_key?(:country)
          params[:shipping_address][:state] = address[:state] if address.has_key?(:state)
          params[:shipping_address][:zip] = address[:zip] if address.has_key?(:zip)
        end
      end

      def add_merchant_key(params)
        # Reference parent options (Gateway constructor)
        params[:merchant_key] = { :group_id => 0, # Why 0?
                                  :login => @options[:login],
                                  :password => @options[:password] }
                                  
        params[:developer_id] = DEVELOPER_ID
        params[:api_version] = API_VERSION
      end

      def build_batch_xml
       xml = Builder::XmlMarkup.new

        xml.instruct!
        xml.tag!('MERCHANT_KEY', XML_ATTRIBUTES) do
          xml.tag! 'GROUPID', 0
          xml.tag! 'SECUREKEY', @options[:password]
          xml.tag! 'SECURENETID', @options[:login]
        end
        
        xml.target!      
      end
      
      def build_transaction_xml(params, money)
        #puts "Building transaction XML: #{params.inspect}"
        xml = Builder::XmlMarkup.new

        xml.instruct!
        xml.tag!('TRANSACTION', XML_ATTRIBUTES) do
          # Amount is the first element anyway, so let this stay
          xml.tag! 'AMOUNT', amount(money)
          # The schema is order dependent. Rather than require all the build methods to know this order, let them
          #   make a regular Ruby hash in a sensible order (which allows factoring out common elements, etc.)
          #   Then put the schema knowledge in one place -- here
          # Could actually read the schema, but it's a little too complex to be worth it with all the embedded objects
          if params.has_key?(:card)
            xml.tag!('CARD') do
              xml.tag! 'CARDCODE', params[:card][:card_code]
              xml.tag! 'CARDNUMBER', params[:card][:card_number]
              xml.tag! 'EXPDATE', params[:card][:expiration_date]
            end
          elsif params.has_key?(:check)
            xml.tag!('CHECK') do
              xml.tag! 'ABACODE', params[:check][:routing_number]
              xml.tag! 'ACCOUNTNAME', params[:check][:account_holder]
              xml.tag! 'ACCOUNTNUM', params[:check][:account_number]
              xml.tag! 'ACCOUNTTYPE', params[:check][:account_type]
              xml.tag! 'BANKNAME', params[:check][:bank_name]
              xml.tag! 'SECCODE', params[:check][:sec_code]
            end
          end
          xml.tag! 'CODE', params[:code]
          xml.tag! 'CUSTOMERID', params[:customer_id] if params.has_key?(:customer_id)
          xml.tag! 'CUSTOMERIP', params[:customer_ip] if params.has_key?(:customer_ip)
          
          xml.tag!('CUSTOMER_BILL') do
            xml.tag! 'ADDRESS', params[:billing_address][:address1] if params[:billing_address].has_key?(:address1)
            xml.tag! 'CITY', params[:billing_address][:city] if params[:billing_address].has_key?(:city)
            xml.tag! 'COMPANY', params[:billing_address][:company] if params[:billing_address].has_key?(:company)
            xml.tag! 'COUNTRY', params[:billing_address][:country] if params[:billing_address].has_key?(:country)
            if params[:billing_address].has_key?(:email)
              xml.tag! 'EMAIL', params[:billing_address][:email] 
              xml.tag! 'EMAILRECEIPT', 'FALSE'
            end
            xml.tag! 'FIRSTNAME', params[:billing_address][:first_name]
            xml.tag! 'LASTNAME', params[:billing_address][:last_name]
            xml.tag! 'PHONE', params[:billing_address][:phone] if params[:billing_address].has_key?(:phone)
            xml.tag! 'STATE', params[:billing_address][:state] if params[:billing_address].has_key?(:state)
            xml.tag! 'ZIP', params[:billing_address][:zip] if params[:billing_address].has_key?(:zip)
          end
          
          if params.has_key?(:shipping_address)
            xml.tag!('CUSTOMER_SHIP') do
              xml.tag! 'ADDRESS', params[:shipping_address][:address1] if params[:shipping_address].has_key?(:address1)
              xml.tag! 'CITY', params[:shipping_address][:city] if params[:shipping_address].has_key?(:city)
              xml.tag! 'COMPANY', params[:shipping_address][:company] if params[:shipping_address].has_key?(:company)
              xml.tag! 'COUNTRY', params[:shipping_address][:country] if params[:shipping_address].has_key?(:country)
              xml.tag! 'FIRSTNAME', params[:shipping_address][:first_name] if params[:shipping_address].has_key?(:first_name)
              xml.tag! 'LASTNAME', params[:shipping_address][:last_name] if params[:shipping_address].has_key?(:last_name)
              xml.tag! 'STATE', params[:shipping_address][:state] if params[:shipping_address].has_key?(:state)
              xml.tag! 'ZIP', params[:shipping_address][:zip] if params[:shipping_address].has_key?(:zip)
            end
          end
          
          xml.tag! 'DCI', params[:dci]
          xml.tag! 'INDUSTRYSPECIFICDATA', params[:industry_specific_data]
          xml.tag! 'INSTALLMENT_SEQUENCENUM', 0 # useless; required by schema
          
          xml.tag!('MERCHANT_KEY') do
            xml.tag! 'GROUPID', params[:merchant_key][:group_id]
            xml.tag! 'SECUREKEY', params[:merchant_key][:password]
            xml.tag! 'SECURENETID', params[:merchant_key][:login]
          end
          
          xml.tag! 'METHOD', params[:method]
          xml.tag! 'ORDERID', params[:order_id]
          xml.tag! 'OVERRIDE_FROM', params[:override_from]
          xml.tag! 'REF_TRANSID', params[:ref_transaction_id] if params.has_key?(:ref_transaction_id)
          xml.tag! 'RETAIL_LANENUM', 0 # useless; required by schema
          xml.tag! 'TEST', params[:test]
          xml.tag! 'TOTAL_INSTALLMENTCOUNT', 0 # useless; required by schema
          xml.tag! 'TRANSACTION_SERVICE', params[:transaction_service]
          xml.tag! 'DEVELOPERID', params[:developer_id]
          xml.tag! 'VERSION', params[:api_version]
        end
           
        xml.target!
      rescue Exception => e
        puts e.message
        
        xml.target!
      end
       
      #########################################################################
      # FUNCTIONS RELATED TO THE RESPONSE
      #########################################################################
      def success?(response)
        response[:response_code].to_i == APPROVED
      end

      def message_from(response)
        if response[:response_code].to_i == DECLINED
          return CVVResult.messages[ response[:card_code_response_code] ] if CARD_CODE_ERRORS.include?(response[:card_code_response_code])
          return AVSResult.messages[ response[:avs_result_code] ] if AVS_ERRORS.include?(response[:avs_result_code])
        end

        return response[:response_reason_text].nil? ? '' : response[:response_reason_text][0..-1]
      end

      def parse(xml)
        #puts "Raw XML response: #{xml}"
        response = {}
        xml = REXML::Document.new(xml)
        root = REXML::XPath.first(xml, "//GATEWAYRESPONSE")# ||
        if root
          root.elements.to_a.each do |node|
            recurring_parse_element(response, node)
          end
        end

        response
      end

      def recurring_parse_element(response, node)
        if node.has_elements?
          node.elements.each{|e| recurring_parse_element(response, e) }
        else
          response[node.name.underscore.to_sym] = node.text
        end
      end      
    end
  end
end
