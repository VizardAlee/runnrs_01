class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @store = @user.store

    # Access orders through order_items and line_items
    @orders = Order.joins(:order_items).where(order_items: { product_id: @store.products.ids }).distinct

    # Alternatively, if you want to stick with flat_map and the model associations approach:
    # @orders = @store.products.flat_map(&:orders).uniq
  end

  def new_logo
    # @store is set by the before_action
  end

  def update_logo
    if @store.logo.attach(params[:store][:logo])
      redirect_to @store, notice: 'Logo was successfully updated.'
    else
      flash.now[:alert] = 'Failed to update logo.'
      render :new_logo
    end
  end
end
