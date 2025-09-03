class MessagesController < ApplicationController
  respond_to :json
  before_action :authenticate_user!
  before_action :set_offer, only: [:create, :fetch_log]

  def create
    render json: { error: "Offer not found" }, status: :not_found and return unless @offer
    render json: { error: "Offer not accepted yet" }, status: :unprocessable_entity and return unless @offer.accepted?
      if build_message.save
        render json: MessageSerializer.new(@message).serializable_hash, status: :created
      else
        render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
      end
  end

  def fetch_log
    render json: { error: "Offer not found" }, status: :not_found and return unless @offer
    set_customer_and_service_provider
    render json: { error: "You must be part of the message log or an admin to view it" }, status: :unauthorized and return unless check_authorization
    messages = Message.fetch_log(@offer.id)

    render json: {
      customer: UserSerializer.new(@customer).serializable_hash,
      service_provider: UserSerializer.new(@service_provider).serializable_hash,
      log: MessageSerializer.new(messages).serializable_hash, 
    }, status: :ok
  end

  private

  def message_params
    params.permit(:body, :offer_id, message_images: [])
  end

  def log_fetch_params
    params.require(:offer_id)
  end

  def set_offer
    @offer = Offer.find_by(id: params[:offer_id])
  end

  def set_customer_and_service_provider
    @customer = User.find_by(id: Task.find_by(id: @offer.task_id).user_id)
    @service_provider = User.find_by(id: @offer.service_provider_id)
  end

  def check_receiver
    return @customer if @service_provider.id != current_user.id
    @service_provider
  end

  def check_authorization
    current_user.id == @customer.id || current_user.id == @service_provider.id || current_user.admin?
  end

  def build_message
    @message = Message.new(
      body: params[:body],
      offer: @offer,
      sender: current_user,
      receiver: check_receiver,
    )
    if message_params[:message_images].present?
      @message.message_images.attach(message_params[:message_images])
    end
    @message
  end
end
