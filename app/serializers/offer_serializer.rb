class OfferSerializer
  include JSONAPI::Serializer
  
  attributes :id, :price, :message, :status, :availability_date, :terms, 
             :accepted_at, :rejected_at, :completion_notes, :completed_at, 
             :created_at, :updated_at, :payment_method

  attribute :service_provider do |offer|
    {
      id: offer.service_provider.id,
      name: offer.service_provider.full_name,
      email: offer.service_provider.email,
      rating: offer.service_provider.rating,
      total_reviews: offer.service_provider.total_reviews,
      user_type: offer.service_provider.user_type
    }
  end
  
  attribute :task do |offer|
    {
      id: offer.task.id,
      title: offer.task.title,
      status: offer.task.status
    }
  end

  attribute :can_be_accepted do |offer|
    offer.can_be_accepted?
  end

  attribute :provider_name do |offer|
    offer.provider_name
  end

  attribute :provider_rating do |offer|
    offer.provider_rating
  end
  
  attribute :payment_info do |offer|
    payment = offer.payment
    if payment
      {
        id: payment.id,
        amount: payment.amount,
        status: payment.status,
        payment_method: payment.payment_method,
        stripe_payment_intent_id: payment.stripe_payment_intent_id
      }
    else
      nil
    end
  end
  
  attribute :completion_photo_urls do |offer|
    offer.completion_photos.map do |photo|
      Rails.application.routes.url_helpers.url_for(photo)
    end
  end
end