class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :first_name, :last_name, :user_type, :location, :longitude, :latitude, :age, :phone, :total_reviews, :rating, :bio, :confirmed_at, :sign_in_count, :created_at, :last_sign_in_at

  attribute :profile_picture_url do |user|
    user.profile_picture.attached? ? Rails.application.routes.url_helpers.url_for(user.profile_picture) : nil
  end
end
