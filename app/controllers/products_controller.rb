class ProductsController < ApplicationController
  before_action :set_store
  before_action :set_store, except: [:index]
  before_action :set_product, only: %i[ show edit update destroy add_quantity create_message ]
  skip_before_action :set_store, only: [:search]

  def index
    @products = Product.order("RANDOM()").paginate(page: params[:page], per_page: 9)
  end

  def new
    @product = @store.products.build
  end

  def create
    @product = @store.products.build(product_params)

    if @product.save
      respond_to do |format|
        format.turbo_stream do 
          render turbo_stream: turbo_stream.replace(
            "new_product_form",
            partial: "products/form", 
            locals: { store: @store, product: Product.new } 
          )
          turbo_stream.append "flash_messages", partial: "layouts/flash_messages"
        end
        
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
    # Store the location if user is not signed in
    store_location_for(:user, request.fullpath) unless user_signed_in?
    @product = @store.products.find(params[:id])
    @negotiation = @product.negotiations.new
    @negotiations = @product.negotiations.includes(:user).order(created_at: :asc)
  end

  def create_message
    @negotiation = @product.negotiations.build(negotiation_params)
    @negotiation.user = current_user
    @negotiation.store = @store  # Ensure the store is set
  
    if @negotiation.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "negotiations",
            partial: "negotiations/negotiation",
            locals: { negotiation: @negotiation }
          )
        end
        format.html { redirect_to store_product_path(@store, @product), notice: "Message sent successfully." }
      end
    else
      respond_to do |format|
        format.html { render :show, status: :unprocessable_entity }
      end
    end
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
    @store = Store.find_by(id: params[:store_id])
    puts "Store ID: #{params[:store_id]}"
    puts "Store: #{@store.inspect}"
    if @store.nil?
      redirect_to root_path, alert: "Store not found"
    end
  end

  def set_product
    @product = @store.products.find_by(id: params[:id])
    if @product.nil?
      redirect_to store_products_path(@store), alert: "Product not found"
    end
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :image, :quantity, :has_variations)
  end

  def negotiation_params
    params.require(:negotiation).permit(:message)
  end
end
