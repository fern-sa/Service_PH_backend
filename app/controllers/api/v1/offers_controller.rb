class Api::V1::OffersController < ApplicationController
  include Pagination
  
  before_action :authenticate_user!
  before_action :set_task
  before_action :set_offer, only: [:show, :accept, :reject, :confirm_cash_payment]
  before_action :authorize_service_provider, only: [:create]
  before_action :authorize_task_owner, only: [:index, :accept, :reject, :confirm_cash_payment]
  before_action :authorize_offer_access, only: [:show]

  def index
    offers = @task.offers.includes(:service_provider).recent
    
    render json: {
      status: { code: 200 },
      data: {
        offers: offers.map { |offer| OfferSerializer.new(offer).serializable_hash[:data][:attributes] },
        task: { id: @task.id, title: @task.title, status: @task.status }
      }
    }
  end

  def show
    render json: {
      status: { code: 200 },
      data: OfferSerializer.new(@offer).serializable_hash[:data][:attributes]
    }
  end

  def create
    @offer = build_offer

    if @offer.save
      render json: {
        status: { code: 201, message: 'Offer submitted successfully' },
        data: OfferSerializer.new(@offer).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: {
        status: { message: "Offer couldn't be created: #{@offer.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end

  def accept
    if @offer.payment_method == 'online'
      # For online payment, process payment first
      payment_result = process_online_payment
      return unless payment_result[:success]
    end

    if @offer.accept!
      # Create payment record
      payment = @offer.create_payment!
      
      if @offer.payment_method == 'online' && payment_result
        payment.update!(
          status: 'escrowed',
          stripe_payment_intent_id: payment_result[:payment_intent_id]
        )
      end

      render json: {
        status: { code: 200, message: 'Offer accepted successfully' },
        data: OfferSerializer.new(@offer.reload).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: { message: 'Unable to accept offer' }
      }, status: :unprocessable_entity
    end
  end

  def reject
    if @offer.reject!
      render json: {
        status: { code: 200, message: 'Offer rejected' },
        data: OfferSerializer.new(@offer.reload).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: { message: 'Unable to reject offer' }
      }, status: :unprocessable_entity
    end
  end

  def confirm_cash_payment
    payment = @offer.payment
    
    unless payment&.cash? && payment.pending?
      return render json: {
        status: { message: 'Cash payment cannot be confirmed' }
      }, status: :unprocessable_entity
    end

    if payment.update(status: 'released')
      render json: {
        status: { code: 200, message: 'Cash payment confirmed' },
        data: OfferSerializer.new(@offer.reload).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: { message: 'Failed to confirm payment' }
      }, status: :unprocessable_entity
    end
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Task not found' }, status: :not_found
  end

  def set_offer
    @offer = @task.offers.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Offer not found' }, status: :not_found
  end

  def offer_params
    params.require(:offer).permit(:price, :message, :availability_date, :terms, :payment_method)
  end

  def build_offer
    offer = @task.offers.build(offer_params)
    offer.service_provider = current_user
    offer
  end

  def authorize_service_provider
    unless current_user.service_provider?
      render json: { error: 'Only service providers can make offers' }, status: :forbidden
    end
  end

  def authorize_task_owner
    unless current_user == @task.user
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end

  def authorize_offer_access
    # Task owner can see any offer on their task
    return if current_user == @task.user
    
    # Service provider can only see their own offers
    if current_user.service_provider? && @offer.service_provider == current_user
      return
    end
    
    render json: { error: 'Not authorized' }, status: :forbidden
  end

  def process_online_payment
    begin
      payment_intent = Stripe::PaymentIntent.create({
        amount: (@offer.price * 100).to_i,
        currency: 'php',
        automatic_payment_methods: { enabled: true },
        metadata: {
          offer_id: @offer.id,
          task_id: @task.id,
          customer_id: current_user.id
        }
      })
      
      {
        success: true,
        payment_intent_id: payment_intent.id,
        client_secret: payment_intent.client_secret
      }
    rescue Stripe::CardError => e
      render json: {
        status: { message: "Payment failed: #{e.user_message}" }
      }, status: :payment_required
      { success: false }
    rescue Stripe::StripeError => e
      render json: {
        status: { message: "Payment processing error: #{e.message}" }
      }, status: :unprocessable_entity
      { success: false }
    end
  end
end