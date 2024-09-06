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
      clear_cart
      clear_cart_session
      Rails.logger.debug "Cart cleared and session reset."
    else
      flash[:error] = "Order could not be saved. Please check your details and try again."
      redirect_to new_checkout_path
    end
  end

  def flutterwave_callback
    Rails.logger.debug("Received params: #{params.inspect}")

    request_body = retrieve_request_body
    return unless validate_signature(request_body)

    payload = parse_json(request_body)
    return if payload.nil?

    tx_ref = extract_tx_ref(payload)
    return unless payment_was_successful?(tx_ref)

    process_order(tx_ref)
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

    puts "Flutterwave Response: #{result.inspect}" # Log the response here
  
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
    begin
      response = Flutterwave::Transaction.verify(tx_ref)

      # Check the response status and data status 
      if response[:status] == 'success' && response[:data][:status] == 'successful'
        true
      else
        false
      end
    rescue => e
      logger.error "Error verifying Flutterwave transaction: #{e.message}\n#{e.backtrace.join("\n")}"
      false
    end
  end

  def retrieve_request_body
    if request.body.present?
      request.body.read
    else
      Rails.logger.error "Empty request body received from Flutterwave"
      flash[:alert] = "Invalid request from payment gateway."
      redirect_to root_path and return
    end
  end
  
  def validate_signature(request_body)
    received_signature = request.headers['HTTP_VERIF_HASH']
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
    
    calculated_signature = OpenSSL::HMAC.hexdigest('SHA256', secret_hash, request_body)
  
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
  
  def process_order(tx_ref)
    @order = Order.find_by(id: tx_ref)
    if @order
      @cart = @order.shopping_cart
      ActiveRecord::Base.transaction do
        @cart.line_items.each do |line_item|
          OrderItem.create!(
            order: @order,
            product: line_item.product,
            quantity: line_item.quantity,
            price: line_item.product.price
          )
          line_item.product.update!(stock: line_item.product.stock - line_item.quantity)
        end
        @cart.update!(status: 'processed')
        Rails.logger.debug "Clearing line items from cart #{@cart.id}"
        @cart.line_items.destroy_all # Clear line items from cart
      end
      clear_cart
      clear_cart_session
      # redirect_to root_path, notice: 'Order completed and cart cleared!'
      redirect_to order_confirmation_path(@order), notice: 'Order placed successfully!'
    else
      Rails.logger.error "Order not found for reference: #{tx_ref}"
      flash[:alert] = "Order not found. Please contact support."
      redirect_to cart_path
    end
  end

  def clear_cart_session
    session[:cart_id] = nil
  end

  def clear_cart
    @cart.line_items.destroy_all
  end
  
end
