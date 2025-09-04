class Payments::CashService < ApplicationService
  def initialize(offer:)
    @offer = offer
    @payment = offer.payment
  end

  def call
    return validation_failure unless valid_for_confirmation?

    confirm_cash_payment
  end

  private

  attr_reader :offer, :payment

  def valid_for_confirmation?
    payment&.cash? && payment.pending?
  end

  def validation_failure
    error_details = build_error_details
    
    failure(
      error_message: 'Cash payment cannot be confirmed',
      errors: error_details
    )
  end

  def build_error_details
    details = []
    details << "No payment found" unless payment
    details << "Payment method is #{payment.payment_method} (expected: cash)" if payment && !payment.cash?
    details << "Payment status is #{payment.status} (expected: pending)" if payment && !payment.pending?
    details
  end

  def confirm_cash_payment
    if payment.update(status: 'released')
      success(payment)
    else
      failure(error_message: 'Failed to update payment status')
    end
  end
end