class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :first_name, :last_name

  attribute :profile_picture_url do |user|
    user.profile_picture.attached? ? Rails.application.routes.url_helpers.url_for(user.profile_picture) : nil
  end
end
