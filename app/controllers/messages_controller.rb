class MessagesController < ApplicationController
  respond_to :json
  before_action :authenticate_user!
  before_action :set_offer, only: [:create]

  def create
    render json: { error: "Offer not found" }, status: :not_found and return unless @offer
      if build_message.save
        render json: MessageSerializer.new(message).serializable_hash, status: :created
      else
        render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
      end
  end

  private

  def message_params
    params.require(:message).permit(:body, :offer_id, message_images: [])
  end

  def set_offer
    @offer = Offer.find_by(id: params[:offer_id])
  end

  def check_receiver
    return @offer.service_provider_id if @offer.service_provider_id == current_user.id
    Task.find_by(id: @offer.task_id).id
  end

  def build_message
    message = Message.new(
      body: params[:body],
      offer: @offer,
      sender: current_user,
      receiver: check_receiver,
    )
    if message_params[:message_images].present?
      message.message_images.attach(message_params[:message_images])
    end
    message
  end
end
