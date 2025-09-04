class Offers::AcceptanceService < ApplicationService
  def initialize(offer:, current_user:)
    @offer = offer
    @current_user = current_user
  end

  def call
    ActiveRecord::Base.transaction do
      process_online_payment if online_payment?
      accept_offer!
      create_payment_record
      update_payment_status if online_payment? && @stripe_result&.success?
      
      success(offer.reload)
    end
  rescue => e
    failure(error_message: e.message)
  end

  private

  attr_reader :offer, :current_user

  def online_payment?
    offer.payment_method == 'online'
  end

  def process_online_payment
    @stripe_result = Payments::StripeService.call(offer: offer, customer: current_user)
    
    unless @stripe_result.success?
      raise @stripe_result.error_message
    end
  end

  def accept_offer!
    unless offer.accept!
      raise "Unable to accept offer: #{offer.errors.full_messages.to_sentence}"
    end
  end

  def create_payment_record
    result = Payments::CreationService.call(offer: offer)
    
    unless result.success?
      raise result.error_message
    end
    
    @payment = result.data
  end

  def update_payment_status
    @payment.update!(
      status: 'escrowed',
      stripe_payment_intent_id: @stripe_result.data[:payment_intent_id]
    )
  end
end