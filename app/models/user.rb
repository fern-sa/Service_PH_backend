class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, 
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_one_attached :profile_picture
  enum user_type: { customer: 0, service_provider: 1, admin: 2 }
  validates :phone, format: { with: /\A09\d{9}\z/, message: "must be 11 digits and start with 09" }
end
