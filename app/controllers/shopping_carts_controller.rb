class ShoppingCartsController < ApplicationController
  def show
    @cart = current_cart
  end

  def add_item
    product = Product.find(params[:product_id])
    variation = product.variations.find(params[:variation_id])
    option = variation.options.find_by(id: params[:option_id]) if params[:option_id]

    current_cart.add_item(product, variation, option)
    # redirect_to shopping_cart_path(current_cart)
  end

end
