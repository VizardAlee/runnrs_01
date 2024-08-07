class LineItemsController < ApplicationController
  def create
    @cart = current_cart
    product = Product.find(params[:product_id])
    variation = Variation.find_by(id: params[:variation_id]) if params[:variation_id]
    quantity = params[:quantity].to_i

    # Ensure quantity is valid
    if quantity <= 0
      redirect_to product_path(product), alert: 'Please enter a valid quantity.' 
      return
    end

    # Calculate the price based on variation or product
    price = variation ? variation.price : product.price

    # Build the line_item with the calculated price
    @line_item = @cart.line_items.build(product: product, variation: variation, quantity: quantity, price: price)

    if @line_item.save
      # Update stock within a transaction 
      ActiveRecord::Base.transaction do
        if variation
          variation.decrement!(:quantity, quantity)
        else
          product.decrement!(:quantity, quantity)
        end
      end 

      respond_to do |format|
        format.turbo_stream { 
          render turbo_stream: 
            turbo_stream.replace('cart', partial: 'shopping_carts/cart', locals: { cart: @cart }) 
        }
        format.html { redirect_to shopping_cart_path(@cart), notice: 'Item added to cart!' }
      end
    else
      # Handle errors (render the product page with an error message)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace('flash_messages', partial: 'shared/flash_messages', locals: { alert: @line_item.errors.full_messages.to_sentence }) }
        format.html { redirect_to product_path(product), alert: @line_item.errors.full_messages.to_sentence }
      end
    end
  end

  def destroy
    @line_item = LineItem.find(params[:id])
    @line_item.destroy

    if @line_item.variation
      @line_item.variation.increment!(:quantity, @line_item.quantity) # Increment variation quantity
    else
      @line_item.product.increment!(:quantity, @line_item.quantity) # Increment product quantity
    end

    redirect_to shopping_cart_path(@line_item.shopping_cart), notice: 'Item removed from cart!'
  end

  private

  def line_item_params
    params.require(:line_item).permit(:product_id, :variation_id, :quantity, :price) 
  end
end
