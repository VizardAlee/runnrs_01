class ProductsController < ApplicationController
  before_action :set_store
  before_action :set_product, only: %i[ show edit update destroy ]

  def index
    @products = Product.all
  end

  def new
    @product = @store.products.build
  end

  def create
    @product = @store.products.build(product_params)
    
    if @product.save
      redirect_to @store, notice: 'Product was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to [@store, @product], notice: 'Product was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def set_store
    @store = Store.find(params[:store_id])
  end

  def set_product
    @product = @store.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :image)
  end
end
