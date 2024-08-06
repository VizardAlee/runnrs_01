class VariationsController < ApplicationController
  before_action :set_store, :set_product
  before_action :set_variation, only: [ :edit, :update, :destroy]
  def new
    @variation = @product.variations.build
  end

  def create
    @variation = @product.variations.build(variation_params)

    if @variation.save
      redirect_to store_product_url(@store, @product), notice: 'Variation was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @variation.update(variation_params)
      redirect_to store_product_url(@store, @product), notice: 'Variation was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @variation.destroy
    redirect_to store_product_url(@store, @product), notice: 'Variation was successfully destroyed.'
  end


  private

  def set_store
    @store = Store.find(params[:store_id])
  end

  def set_product
    @product = @store.products.find(params[:product_id])
  end

  def variation_params
    params.require(:variation).permit(:name, :price, :quantity)
  end

  def set_variation
    @variation = @product.variations.find(params[:id])
  end
end

