class Api::V1::PaymentsController < ApplicationController
  include ApiResponse
  include ErrorHandling
  include Serialization
  include Authorization
  
  before_action :authenticate_user!
  before_action :set_offer
  before_action :authorize_payment_access

  def create
    result = Payments::CreationService.call(offer: @offer, payment_method: payment_params[:payment_method])
    
    if result.success?
      render_created(
        data: serialized_payment(result.data),
        message: 'Payment created successfully'
      )
    else
      handle_service_error(result)
    end
  end

  def confirm_cash
    result = Payments::CashService.call(offer: @offer)
    
    if result.success?
      render_success(
        data: serialized_payment(result.data),
        message: 'Cash payment confirmed'
      )
    else
      handle_service_error(result)
    end
  end

  def stripe_intent
    result = Payments::StripeService.call(offer: @offer, customer: current_user)
    
    if result.success?
      render_success(
        data: result.data,
        message: 'Payment intent created'
      )
    else
      handle_service_error(result)
    end
  end

  private

  def set_offer
    @offer = Offer.find(params[:offer_id])
  end

  def payment_params
    params.require(:payment).permit(:payment_method)
  end

end