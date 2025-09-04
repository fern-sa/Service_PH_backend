class Api::V1::OffersController < ApplicationController
  include Pagination
  include ApiResponse
  include ErrorHandling
  include Serialization
  include Authorization
  
  before_action :authenticate_user!
  before_action :set_task
  before_action :set_offer, only: [:show, :accept, :reject, :confirm_cash_payment]
  before_action :authorize_service_provider, only: [:create]
  before_action :authorize_task_owner, only: [:index, :accept, :reject, :confirm_cash_payment]
  before_action :authorize_offer_access, only: [:show]

  def index
    offers = @task.offers.includes(:service_provider).recent
    
    render_success(data: {
      offers: serialized_offers(offers),
      task: task_summary
    })
  end

  def show
    render_success(data: serialized_offer(@offer))
  end

  def create
    @offer = build_offer

    if @offer.save
      render_created(
        data: serialized_offer(@offer),
        message: 'Offer submitted successfully'
      )
    else
      render_error(
        message: "Offer couldn't be created: #{@offer.errors.full_messages.to_sentence}"
      )
    end
  end

  def accept
    result = Offers::AcceptanceService.call(offer: @offer, current_user: current_user)
    
    if result.success?
      render_success(
        data: serialized_offer(result.data),
        message: 'Offer accepted successfully'
      )
    else
      handle_service_error(result)
    end
  end

  def reject
    result = Offers::RejectionService.call(offer: @offer)
    
    if result.success?
      render_success(
        data: serialized_offer(result.data),
        message: 'Offer rejected'
      )
    else
      handle_service_error(result)
    end
  end

  def confirm_cash_payment
    result = Payments::CashService.call(offer: @offer)
    
    if result.success?
      render_success(
        data: serialized_offer(@offer.reload),
        message: 'Cash payment confirmed'
      )
    else
      handle_service_error(result)
    end
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def set_offer
    @offer = @task.offers.find(params[:id])
  end

  def offer_params
    params.require(:offer).permit(:price, :message, :availability_date, :terms, :payment_method)
  end

  def build_offer
    offer = @task.offers.build(offer_params)
    offer.service_provider = current_user
    offer
  end

end