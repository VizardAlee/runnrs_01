class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @orders = current_user.store.products.flat_map(&:orders)
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
