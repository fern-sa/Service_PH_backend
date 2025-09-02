class MessageSerializer < ActiveModel::Serializer
  include JSONAPI::Serializer
  attributes :id, :body, :sender_id, :receiver_id, :offer_id, :created_at

  attribute :message_images_urls do |msg|
    if msg.message_images.attached?
      msg.message_images.map do |img|
        Rails.application.routes.url_helpers.url_for(img)
      end
    else
      []
    end
  end
  
end