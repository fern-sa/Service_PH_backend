class OfferSerializer
  include JSONAPI::Serializer
  
  attributes :id, :price, :message, :status, :availability_date, :terms, 
             :accepted_at, :rejected_at, :completion_notes, :completed_at, 
             :created_at, :updated_at

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
end