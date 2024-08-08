class OrdersController < ApplicationController
  def create
    @cart = current_cart
    @order = Order.new(order_params)
    @order.status = 'unfulfilled'
    @order.user = current_user if user_signed_in? # Associate order with user if logged in
    @order.shopping_cart = @cart
    @order.total = @cart.total

    begin
      if @order.save
        # Dummy payment processing (simulate success)
        sleep(2) 
  
        # Mark cart as checked out and update product quantities
        @cart.update(status: "checked_out")
        @cart.line_items.each do |line_item|
          if line_item.variation
            line_item.variation.update(quantity: line_item.variation.quantity - line_item.quantity) 
          else
            line_item.product.update(quantity: line_item.product.quantity - line_item.quantity)
          end
        end
  
        # Send confirmation email (you'll need to implement this later)
        # ...
  
        respond_to do |format|
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace('cart', partial: 'orders/order_confirmation', locals: { order: @order }) 
          }
          format.html { redirect_to root_path, notice: 'Order placed successfully!' } # Redirect to home page or another suitable page
        end
      else
        render :new 
      end
  
    rescue => e # Catch any other exceptions
      # Log the error for debugging
      logger.error "Error during checkout: #{e.message}\n#{e.backtrace.join("\n")}"
  
      # Render the new view with a generic error message
      flash.now[:alert] = "An error occurred during checkout. Please try again later."
      render :new
    end
  end

  def index
    @orders = current_user.store.products.flat_map(&:orders).select { |order| order.status == 'unfulfilled' }
  end

  def show
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    @order.update(status: 'fulfilled')
    redirect_to orders_path, notice: 'Order marked as fulfilled.'
  end

  private

  def order_params
    params.require(:order).permit(:email, :shipping_address, :billing_address, :payment_method) # Adjust based on your Order model
  end
end
