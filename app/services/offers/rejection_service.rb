class Offers::RejectionService < ApplicationService
  def initialize(offer:)
    @offer = offer
  end

  def call
    if offer.reject!
      success(offer.reload)
    else
      failure(error_message: "Unable to reject offer: #{offer.errors.full_messages.to_sentence}")
    end
  end

  private

  attr_reader :offer
end