class CartsController < ApplicationController
  def show
    @cart = current_user.cart # Fetch the current user's cart
  end

  def add_item
    @cart = current_cart
    product = Product.find(params[:product_id])

    variation = product.variations.find(params[:variation_id])
    option = variation.options.find(params[:option_id]) if params[:option_id]

    @cart.add_item(product, variation, option) # Pass variation and option
    redirect_to cart_path(@cart)
  end
end
