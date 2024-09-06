class StoresController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :set_store, only: [:show, :new_logo, :update_logo]

  def new
    @store = Store.new
  end

  def index
    @orders = current_user.store.orders.where(status: 'unfulfilled')
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

  def dashboard
    @store = current_user.store # Assuming the user has only one store for now
    # You can add other relevant data for the dashboard here
  end

  def show
    @store = Store.find(params[:id])
    @products = @store.products.paginate(page: params[:page], per_page: 9)
  end

  def new_logo
    @store = Store.find(params[:id])
    # @store is set by the before_action
  end

  def update_logo
    @store = Store.find(params[:id])
    if @store.update(logo_params)
      redirect_to profile_path, notice: 'Logo was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_store
    @store = Store.find(params[:id])
  end

  def store_params
    params.require(:store).permit(:name, :description, :logo)
  end

  def logo_params
    params.require(:store).permit(:logo)
  end
end
