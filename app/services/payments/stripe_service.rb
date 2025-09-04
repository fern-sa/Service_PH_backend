class Payments::StripeService < ApplicationService
  def initialize(offer:, customer:)
    @offer = offer
    @customer = customer
  end

  def call
    create_payment_intent
  rescue Stripe::CardError => e
    failure(
      error_message: "Payment failed: #{e.user_message}",
      status: :payment_required
    )
  rescue Stripe::StripeError => e
    failure(
      error_message: "Payment processing error: #{e.message}",
      status: :unprocessable_entity
    )
  end

  private

  attr_reader :offer, :customer

  def create_payment_intent
    payment_intent = Stripe::PaymentIntent.create(payment_intent_params)
    
    success({
      payment_intent_id: payment_intent.id,
      client_secret: payment_intent.client_secret
    })
  end

  def payment_intent_params
    {
      amount: (offer.price * 100).to_i, # Stripe uses cents
      currency: 'php',
      automatic_payment_methods: { enabled: true },
      metadata: {
        offer_id: offer.id,
        task_id: offer.task.id,
        customer_id: customer.id
      }
    }
  end
end