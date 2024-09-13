class OrdersController < ApplicationController
  def create
    @cart = current_cart
    @order = Order.new(order_params)
    @order.status = 'unfulfilled'
    @order.user = current_user if user_signed_in?
    @order.shopping_cart = @cart
    @order.total = @cart.total

    begin
      if @order.save
        # Simulate payment processing
        sleep(2)

        # Update cart and product quantities
        @cart.update(status: "checked_out")
        @cart.line_items.each do |line_item|
          if line_item.variation
            line_item.variation.update(quantity: line_item.variation.quantity - line_item.quantity)
          else
            line_item.product.update(quantity: line_item.product.quantity - line_item.quantity)
          end
        end

        # Render response
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace('cart', partial: 'orders/order_confirmation', locals: { order: @order }) }
          format.html { redirect_to root_path, notice: 'Order placed successfully!' }
        end
      else
        render :new
      end

    rescue => e
      logger.error "Error during checkout: #{e.message}\n#{e.backtrace.join("\n")}"
      flash.now[:alert] = "An error occurred during checkout. Please try again later."
      render :new
    end
  end

  def index
    @orders = fetch_orders_by_status('unfulfilled')
    @fulfilled_orders = fetch_orders_by_status('fulfilled')
    @income_data = @fulfilled_orders.group_by_day(:created_at).sum(:total).transform_keys do |date|
      date.strftime('%Y-%m-%d')  # Format the date as YYYY-MM-DD
    end
    Rails.logger.debug "Fulfilled Orders: #{@fulfilled_orders.inspect}"
    Rails.logger.debug "Income Data: #{@income_data.inspect}"
  end

  def show
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    if @order.update(status: 'fulfilled')
      redirect_to orders_path, notice: 'Order marked as fulfilled.'
    else
      redirect_to orders_path, alert: 'Failed to mark order as fulfilled.'
    end
  end

  def income_chart
    @orders = fetch_orders_by_status('fulfilled')
    @income_data = @fulfilled_orders.group_by_day(:created_at).sum(:total).map do |date, total|
      [date.to_s, total] # Ensure the date is a string and total is numeric
    end
  end

  def confirmation
    @order = Order.find_by(id: params[:id])
    Rails.logger.debug "Order: #{@order.inspect}"
    if @order.nil?
      redirect_to root_path, alert: "Order not found"
    end
  end

  private

  def order_params
    params.require(:order).permit(:email, :shipping_address, :billing_address, :payment_method)
  end

  def fetch_orders_by_status(status)
    return [] unless current_user&.store&.products
  
    product_ids = current_user.store.products.pluck(:id)
    
    # Find orders with products linked to the current user's store
    Order.joins(shopping_cart: :line_items)
         .where(line_items: { product_id: product_ids })
         .where(status: status)
         .distinct
  end
  
end
