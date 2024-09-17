class RepliesController < ApplicationController
  before_action :set_negotiation

  def create
    @reply = @negotiation.replies.build(reply_params)
    @reply.user = current_user

    if @reply.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append("negotiation_#{@negotiation.id}_replies", partial: "replies/reply", locals: { reply: @reply }) }
        format.html { redirect_to store_negotiation_path(@negotiation.store, @negotiation), notice: "Reply sent successfully." }
      end
    else
      respond_to do |format|
        format.html { render "negotiations/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def set_negotiation
    @negotiation = Negotiation.find(params[:negotiation_id])
  end

  def reply_params
    params.require(:reply).permit(:message)
  end
end
