class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @orders = current_user.store.products.flat_map(&:orders)
  end
end
