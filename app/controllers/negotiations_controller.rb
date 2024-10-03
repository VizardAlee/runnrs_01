class NegotiationsController < ApplicationController
  before_action :set_store_and_product, only: [:create]
  before_action :set_store, only: [:index, :show]
  before_action :set_negotiation, only: [:show, :create_reply, :accept_offer]

  def accept_offer
    if @negotiation.update(agreed_price: params[:agreed_price])
      redirect_to store_negotiation_path(@store, @negotiation), notice: "Offer accepted. The customer can now pay #{@negotiation.agreed_price} Naira."
    else
      redirect_to store_negotiation_path(@store, @negotiation), alert: "Failed to accept the offer."
    end
  end

  def create
    @negotiation = @product.negotiations.build(negotiation_params)
    @negotiation.user = current_user
    @negotiation.store = @store

    # Set the shop_owner_id to the store's owner
    @negotiation.shop_owner_id = @store.user_id if @store.present?

    if @negotiation.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append("negotiations", partial: "negotiations/negotiation", locals: { negotiation: @negotiation }) }
        format.html { redirect_to store_product_path(@store, @product), notice: "Message sent successfully." }
      end
    else
      respond_to do |format|
        format.html { render :show, status: :unprocessable_entity }
      end
    end
  end

  def index
    @negotiations = @store.negotiations.includes(:user, :product).order(created_at: :desc)
  end

  def show
    # @negotiation is set by the set_negotiation before_action
    @replies = @negotiation.replies
  end

  def create_reply
    @reply = @negotiation.replies.build(reply_params)
    @reply.user = current_user

    if @reply.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append("replies", partial: "replies/reply", locals: { reply: @reply }) }
        format.html { redirect_to store_negotiation_path(@store, @negotiation), notice: "Reply sent successfully." }
      end
    else
      respond_to do |format|
        format.html { render :show, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_store_and_product
    @store = Store.find(params[:store_id])
    @product = @store.products.find(params[:product_id])
  end

  def set_store
    @store = Store.find(params[:store_id])
    Rails.logger.debug("Loaded store: #{@store.inspect}")
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Store not found."
    redirect_to root_path  # Or wherever appropriate
  end
  

  def set_negotiation
    @store = Store.find(params[:store_id])  # Ensure @store is set first
    @negotiation = @store.negotiations.includes(replies: :user).find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash[:alert] = "Negotiation not found or store not found."
    redirect_to store_negotiations_path(params[:store_id])  # Redirecting to the store negotiations index
  end
  

  def negotiation_params
    params.require(:negotiation).permit(:message)
  end

  def reply_params
    params.require(:reply).permit(:message)
  end
end
