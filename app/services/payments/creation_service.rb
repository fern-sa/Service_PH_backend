class Payments::CreationService < ApplicationService
  def initialize(offer:)
    @offer = offer
  end

  def call
    return success(existing_payment) if existing_payment

    create_payment_record
  end

  private

  attr_reader :offer

  def existing_payment
    @existing_payment ||= offer.payment
  end

  def create_payment_record
    payment = Payment.create!(payment_params)
    success(payment)
  rescue ActiveRecord::RecordInvalid => e
    failure(error_message: "Payment creation failed: #{e.record.errors.full_messages.to_sentence}")
  end

  def payment_params
    {
      task: offer.task,
      offer: offer,
      amount: offer.price,
      payment_method: offer.payment_method
    }
  end
end