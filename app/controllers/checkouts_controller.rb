require 'net/http'
require 'uri'
require 'openssl'
require 'base64'

class CheckoutsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:flutterwave_callback]

  def new
    @cart = current_cart
    @order = Order.new
  end

  def create
    @cart = current_cart
    @order = Order.new(order_params)
    @order.status = 'unfulfilled'
    @order.user = current_user if user_signed_in?
    @order.shopping_cart = @cart
    @order.total = @cart.subtotal
    
    if @order.save
      case @order.payment_method
      when 'paystack'
        process_paystack_payment
      when 'flutterwave'
        process_flutterwave_payment
      else
        flash[:error] = "Invalid payment method selected."
        redirect_to new_checkout_path
        return
      end
    else
      flash[:error] = "Order could not be saved. Please check your details and try again."
      redirect_to new_checkout_path
    end
  end

  def flutterwave_callback
    Rails.logger.debug("Received params: #{params.inspect}")
    Rails.logger.debug "FULL URL: #{request.original_url}"
  
    # Check if it's a GET request
    if request.get?
      # Handle GET request parameters
      tx_ref = params[:tx_ref]
      status = params[:status]
      transaction_id = params[:transaction_id]
  
      Rails.logger.debug "Processing GET request with tx_ref: #{tx_ref}, status: #{status}, transaction_id: #{transaction_id}"
      
      # Fetch and display the transaction summary based on the GET request parameters
      @transaction_summary = fetch_transaction_details(transaction_id)
      
      if @transaction_summary
        Rails.logger.debug "Transaction Summary: #{@transaction_summary.inspect}"
        process_order(tx_ref)
      else
        Rails.logger.error "No transaction details found for transaction reference: #{tx_ref}"
        flash[:alert] = "Transaction details are not available at the moment."
        redirect_to root_path and return
      end
  
    # Check if it's a POST request
    elsif request.post?
      request_body = retrieve_request_body
      return unless request_body.present?
  
      # Un-comment these lines if you are validating the signature
      # received_signature = request.headers['x-flutterwave-signature']
      # if received_signature.blank?
      #   Rails.logger.warn "Received signature is nil. Check request headers."
      #   flash[:alert] = "Invalid request from payment gateway."
      #   redirect_to root_path and return
      # end
  
      payload = parse_json(request_body)
      return if payload.nil?
  
      tx_ref = extract_tx_ref(payload)
      return unless tx_ref.present?
  
      Rails.logger.debug "Processing POST request with tx_ref: #{tx_ref}"
  
      @transaction_summary = fetch_transaction_details(tx_ref)
  
      if @transaction_summary
        Rails.logger.debug "Transaction Summary: #{@transaction_summary.inspect}"
        process_order(tx_ref)
        clear_cart
      else
        Rails.logger.error "No transaction details found for transaction reference: #{tx_ref}"
        flash[:alert] = "Transaction details are not available at the moment."
        redirect_to root_path and return
      end
  
    else
      Rails.logger.error "Unsupported request method: #{request.method}"
      flash[:alert] = "Unsupported request method."
      redirect_to root_path and return
    end
  end

  private

  def order_params
    params.require(:order).permit(:email, :shipping_address, :billing_address, :payment_method)
  end

  def process_paystack_payment
    # Paystack payment code here
  end
  
  def process_flutterwave_payment
    uri = URI.parse("https://api.flutterwave.com/v3/payments")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if Rails.env.development? || Rails.env.test? # Skip SSL verification (not recommended for production)
  
    request = Net::HTTP::Post.new(uri.path, {
      'Authorization' => "Bearer #{ENV['FLUTTERWAVE_SECRET_KEY']}",
      'Content-Type' => 'application/json'
    })
    request.body = {
      tx_ref: @order.id.to_s,
      amount: @order.total.to_f,
      currency: 'NGN',
      redirect_url: flutterwave_callback_url,
      customer: {
        email: @order.email
      },
      payment_options: 'card, ussd, banktransfer'
    }.to_json
  
    response = http.request(request)
    result = JSON.parse(response.body)

    Rails.logger.debug "Flutterwave Response: #{result.inspect}" # Log the response here
  
    if result['status'] == 'success'
      redirect_to result['data']['link'], allow_other_host: true
    else
      flash[:error] = "Flutterwave initialization error: #{result['message']}"
      redirect_to new_checkout_path
    end
  end

  def flutterwave_callback_url
    # Use Rails' url helpers to generate the full callback URL
    protocol = Rails.env.production? ? 'https' : 'http'
    host = Rails.env.production? ? 'the-domain.com' : 'localhost:3000'
    url_for(controller: 'checkouts', action: 'flutterwave_callback', only_path: false, protocol: protocol, host: host)
  end

  def payment_was_successful?(tx_ref)
    # Verify the transaction with Flutterwave
    # begin
    #   response = Flutterwave::Transaction.verify(tx_ref)

    #   # Check the response status and data status 
    #   if response[:status] == 'success' && response[:data][:status] == 'successful'
    #     clear_cart
    #     flash[:success] = "Checkout completed successfully!"
    #     true
    #   else
    #     flash[:error] = "Payment failed, please try again."
    #     false
    #   end
    # rescue => e
    #   logger.error "Error verifying Flutterwave transaction: #{e.message}\n#{e.backtrace.join("\n")}"
    #   false
    # end

    begin
      uri = URI.parse("https://api.flutterwave.com/v3/transactions/#{tx_ref}/verify")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.path, {
        'Authorization' => "Bearer #{ENV['FLUTTERWAVE_SECRET_KEY']}"
      })

      response = http.request(request)

      Rails.logger.debug "Response Code: #{response.code}"
      Rails.logger.debug "Response Headers: #{response.to_hash.inspect}"
      Rails.logger.debug "Response Body: #{response.body}"

      result = JSON.parse(response.body)

      # Check the response status and data status 
      if result['status'] == 'success' && result['data']['status'] == 'successful'
        flash[:success] = "Checkout completed successfully!"
        true
      else
        flash[:error] = "Payment failed, please try again."
        false
      end
    rescue => e
      logger.error "Error verifying Flutterwave transaction: #{e.message}\n#{e.backtrace.join("\n")}"
      false
    end
  end

  def retrieve_request_body
    if request.body.present?
      Rails.logger.debug "Request Body Present: #{request.body.read}"
      request.body.rewind
      request.body
    else
      Rails.logger.error "Empty request body received from Flutterwave"
      flash[:alert] = "Invalid request from payment gateway."
      redirect_to root_path and return
    end
  end
  
  def validate_signature(request_body)
    received_signature = request.headers['x-flutterwave-signature']
    Rails.logger.debug "Received signature: #{received_signature}"

    secret_hash = ENV['FLUTTERWAVE_SECRET_HASH']

    if secret_hash.nil?
      Rails.logger.error "FLUTTERWAVE_SECRET_HASH is not set."
      flash[:alert] = "Internal server error. Please contact support."
      redirect_to root_path and return false
    end
  
    if received_signature.nil?
      Rails.logger.error "Received signature is nil. Check request headers."
      flash[:alert] = "Invalid request from payment gateway."
      redirect_to root_path and return false
    end
    
    calculated_signature = OpenSSL::HMAC.hexdigest('SHA256', secret_hash, request_body.read)
    Rails.logger.debug "Calculated signature: #{calculated_signature}"
  
    unless ActiveSupport::SecurityUtils.secure_compare(received_signature, calculated_signature)
      Rails.logger.error "Invalid webhook signature."
      flash[:alert] = "Invalid webhook signature."
      redirect_to root_path and return false
    end
    true
  end
  
  def parse_json(request_body)
    JSON.parse(request_body)
  rescue JSON::ParserError => e
    Rails.logger.error "JSON parse error: #{e.message}"
    flash[:alert] = "Invalid JSON received from payment gateway."
    redirect_to root_path and return nil
  end

  def extract_tx_ref(payload)
    data = payload['data'] || {}
    data['tx_ref'] || data['orderRef']
  end

  def fetch_transaction_details(transaction_id)
    begin
      uri = URI.parse("https://api.flutterwave.com/v3/transactions/#{transaction_id}/verify")
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{ENV['FLUTTERWAVE_SECRET_KEY']}"

      req_options = {
        use_ssl: uri.scheme == "https",
        verify_mode: OpenSSL::SSL::VERIFY_NONE # Disable SSL verification temporarily
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      Rails.logger.debug "HTTP Response Code: #{response.code}"
      Rails.logger.debug "HTTP Response Body: #{response.body}"

      if response.code == "200"
        json_response = JSON.parse(response.body)
        Rails.logger.debug "Parsed JSON Response: #{json_response.inspect}"

        if json_response["status"] == "success"
          transaction_data = json_response["data"]
          {
            transaction_id: transaction_data["id"],
            amount: transaction_data["amount"],
            currency: transaction_data["currency"],
            status: transaction_data["status"],
            payment_method: transaction_data["payment_type"],
            order_reference: transaction_data["tx_ref"],
            customer_email: transaction_data["customer"]["email"],
            payment_date: transaction_data["created_at"]
          }
        else
          Rails.logger.error "Failed to fetch transaction details: #{json_response['message']}"
          nil
        end
      else
        Rails.logger.error "HTTP error fetching transaction details: #{response.code} - #{response.body}"
        nil
      end

    rescue => e
      
      Rails.logger.error "Error fetching transaction details: #{e.message}"
      nil
    end
  end
  

  def process_order(tx_ref)
    Rails.logger.debug "Entering process_order with tx_ref: #{tx_ref}"
    @order = Order.find_by(id: tx_ref)
    
    if @order
      @cart = @order.shopping_cart
      Rails.logger.debug "Processing order #{@order.id} with cart #{@cart.id}"

      ActiveRecord::Base.transaction do
        @cart.line_items.each do |line_item|
          Rails.logger.debug "Processing LineItem ID: #{line_item.id}, Product ID: #{line_item.product.id}, Quantity: #{line_item.quantity}"
          
          # Ensure the line_item exists before creating the OrderItem
          if line_item.variation
            # deduct quantity from variation
            variation = line_item.variation
            if variation.quantity >= line_item.quantity
              variation.update!(quantity: variation.quantity - line_item.quantity)
            else
              rails ActiveRecord::RecordInvalid.new(variation)
            end
          else
            product = line_item.product
            if product.quantity >= line_item.quantity
              product.update!(quantity: product.quantity - line_item.quantity)
            else
              raise ActiveRecord::RecordInvalid.new(product)
            end
          end
          OrderItem.create!(
            order_id: @order.id,
            line_item_id: line_item.id,
            product_id: line_item.product_id,
            quantity: line_item.quantity,
            price: line_item.price
          )
        end

        @cart.update!(status: 'processed')
        Rails.logger.debug "Cart status updated to 'processed'"
      end
  
      Rails.logger.debug "Order processed successfully"
      redirect_to order_confirmation_path(@order), notice: 'Order placed successfully!'
    else
      Rails.logger.error "Order not found for reference: #{tx_ref}"
      flash[:alert] = "Order not found. Please contact support."
      redirect_to root_path, alert: 'Order not found'
    end
  end
  

  def clear_cart
    Rails.logger.debug "Entering clear_cart method"
    cart = current_cart
    Rails.logger.debug "Current cart ID: #{cart&.id}"
    if cart
      Rails.logger.debug "Clearing line items for cart ID: #{cart.id}"
      cart.line_items.destroy_all
      Rails.logger.debug "Line items cleared"
      Rails.logger.debug "Clearing cart session for cart ID: #{cart.id}"
      clear_cart_session
      Rails.logger.debug "Cart session cleared"
    else
      Rails.logger.error "Cart is nil. Nothing to clear."
    end
    Rails.logger.debug "Exiting clear_cart method"
  end
  

  def clear_cart_session
    session[:cart_id] = nil
  end
end
