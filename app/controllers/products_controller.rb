class ProductsController < ApplicationController
  before_action :set_store
  before_action :set_product, only: %i[ show edit update destroy add_quantity]

  skip_before_action :set_store, only: [:search]
  def index
    @products = Product.all
  end

  def new
    @product = @store.products.build
  end

  def create
    @product = @store.products.build(product_params)

    if @product.save
      respond_to do |format|
        format.turbo_stream do 
          # Replace the form with a new, empty form
          render turbo_stream: turbo_stream.replace(
            "new_product_form",
            partial: "products/form", 
            locals: { store: @store, product: Product.new } 
          )

          # Append a flash message to indicate success
          turbo_stream.append "flash_messages", partial: "layouts/flash_messages"
        end
        
        # Redirect to the product's show page using Turbo Stream
        format.turbo_stream { turbo_stream.redirect_to store_product_path(@store, @product) } 
        format.html { redirect_to [@store, @product], notice: 'Product was successfully created.', data: { turbo: false } }
      end
    else
      respond_to do |format|
        format.turbo_stream do 
          render turbo_stream: turbo_stream.replace(
            "new_product_form", 
            partial: "products/form", 
            locals: { store: @store, product: @product }
          )
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def show
    @store = Store.find(params[:store_id])
    @product = @store.products.find(params[:id])
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

  def search
    @query = params[:query]
    if @query.blank?
      redirect_to root_path, alert: 'Please enter a search query.'
    else
      @products = Product.where("name ILIKE ?", "%#{@query}%")
      render :search
    end
  end

  def add_quantity
    @product = @store.products.find(params[:id])
    new_quantity = params[:product][:quantity].to_i
    puts "Params: #{params.inspect}" 
    puts "New Quantity: #{new_quantity}"
  
    if @product.update(quantity: @product.quantity.to_i + new_quantity)
      puts "Update successful!"
      redirect_to [@store, @product], notice: 'Quantity was successfully updated.'
    else
      puts "Update failed! Errors: #{@product.errors.full_messages}"
      render :show, status: :unprocessable_entity 
    end
  end

  private

  def set_store
    @store = Store.find(params[:store_id])
  end

  def set_product
    @product = @store.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :image, :quantity, :has_variations)
  end
end
