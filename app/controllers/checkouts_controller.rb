class CheckoutsController < ApplicationController
  def new
    @cart = current_cart
    @order = Order.new
  end

  def create
    @cart = current_cart
    @order = Order.new(order_params)
    @order.user = current_user if user_signed_in? 
    @order.shopping_cart = @cart
    @order.total = @cart.total 

    if @order.save
      # Placeholder for payment processing (you'll implement this later)
      # ... (e.g., integrate with Paystack or Flutterwave)

      @cart.update(status: "checked_out")
      # Send confirmation email
      # ... 

      redirect_to order_confirmation_path(@order), notice: 'Order placed successfully!'
    else
      render :new
    end
  end

  private

  def order_params
    params.require(:order).permit(:email, :shipping_address, :billing_address, :payment_method) 
  end
end
