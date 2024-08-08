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
      # Dummy payment processing (simulate success)
      sleep(2) # Simulate a short delay

      @cart.update(status: "checked_out")
      @cart.line_items.each do |line_item|
        if line_item.variation
          line_item.variation.update(quantity: line_item.variation.quantity - line_item.quantity) 
        else
          line_item.product.update(quantity: line_item.product.quantity - line_item.quantity)
        end
      end

      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace('cart', partial: 'orders/order_confirmation', locals: { order: @order }) 
        }
        format.html { redirect_to root_path, notice: 'Order placed successfully!' } 
      end
    else
      render :new
    end
  end

  private

  def order_params
    params.require(:order).permit(:email, :shipping_address, :billing_address, :payment_method) 
  end
end
