class StoresController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def new
    @store = Store.new
  end

  def index
    if current_user && current_user.store
      redirect_to current_user.store
    else
      redirect_to root_path # Or another appropriate page
    end
  end

  def create
    if current_user.store.present?
      redirect_to root_path, alert: 'You already have a store.'
    else
      @store = current_user.build_store(store_params)
      if @store.save
        current_user.update(role: :store_owner)

        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "store_form", 
              partial: "stores/new", 
              locals: { store: Store.new }
            )
            flash.now[:notice] = 'Store was successfully created.'

            # Redirect using Turbo Stream
            turbo_stream.update "store_details", partial: "stores/store_details", locals: { store: @store }
          end
          format.html { redirect_to @store, notice: 'Store was successfully created.', data: { turbo: false } } 
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "store_form", 
              partial: "stores/new", 
              locals: { store: @store }
            )
          end
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end
  end

  def show
    @store = Store.find(params[:id])
    @products = @store.products
  end

  private

  def store_params
    params.require(:store).permit(:name, :description)
  end
end
