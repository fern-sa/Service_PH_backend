class MessageSerializer < ActiveModel::Serializer
  include JSONAPI::Serializer
  attributes :id, :body, :sender_id, :receiver_id, :offer_id, :message_image_urls, :created_at

  def message_image_urls
    if object.message_images.attached?
      object.message_images.map do |img|
        Rails.application.routes.url_helpers.url_for(img)
      end
    else
      []
    end
  end
end