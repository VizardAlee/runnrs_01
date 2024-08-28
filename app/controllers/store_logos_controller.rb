class StoreLogosController < ApplicationController
  before_action :set_store

  def new
    # Render a form for uploading the logo
  end

  def create
    if params[:store_logo].present?
      @store.logo.attach(params[:store_logo])
      redirect_to @store, notice: 'Logo was successfully added.'
    else
      render :new
    end
  end

  private

  def set_store
    @store = Store.find(params[:store_id])
  end
end
