require 'net/http'
require 'uri'

class CheckoutsController < ApplicationController
  def new
    @cart = current_cart
    @order = Order.new 
  end

  def create
    @cart = current_cart
    @order = Order.new(order_params)
    @order.status = 'awaiting payment'
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
      end
    else
      flash[:error] = "Order could not be saved. Please check your details and try again."
      redirect_to new_checkout_path
    end
  end
  
  def flutterwave_callback
    request_body = request.body.read
    received_signature = request.headers['HTTP_VERIF_HASH']
    expected_signature = ENV['FLUTTERWAVE_SECRET_HASH'] # Set this in your environment variables
  
    if received_signature == expected_signature
      payload = JSON.parse(request_body)
      data = payload['data']
  
      if payload['status'] == 'successful' && data['status'] == 'successful'
        @order = Order.find_by(id: data['tx_ref'])
        
        if @order
          @cart = @order.shopping_cart
          @cart.update(status: 'checked_out')
  
          @cart.line_items.each do |line_item|
            if line_item.variation
              line_item.variation.update(quantity: line_item.variation.quantity - line_item.quantity)
            else
              line_item.product.update(quantity: line_item.product.quantity - line_item.quantity)
            end
          end
  
          redirect_to order_confirmation_path(@order), notice: 'Order placed successfully!'
        else
          logger.error "Order not found for reference: #{data['tx_ref']}"
          flash[:alert] = "Order not found. Please contact support."
          redirect_to root_path
        end
      else
        flash[:alert] = "Payment failed or invalid event."
        redirect_to checkout_path
      end
    else
      flash[:alert] = "Invalid webhook signature."
      redirect_to root_path
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
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Skip SSL verification (not recommended for production)
  
    request = Net::HTTP::Post.new(uri.path, {
      'Authorization' => "Bearer #{ENV['FLUTTERWAVE_SECRET_KEY']}",
      'Content-Type' => 'application/json'
    })
    request.body = {
      tx_ref: @order.id.to_s,
      amount: @order.total.to_s,
      currency: 'NGN',
      redirect_url: flutterwave_callback_url,
      customer: {
        email: @order.email
      },
      payment_type: 'card'
    }.to_json
  
    response = http.request(request)
    result = JSON.parse(response.body)
  
    if result['status'] == 'success'
      redirect_to result['data']['link'], allow_other_host: true
    else
      flash[:error] = "Flutterwave initialization error: #{result['message']}"
      redirect_to new_checkout_path
    end
  end
end
