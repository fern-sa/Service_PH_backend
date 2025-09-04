class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  before_create :prevent_admin_signup

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, 
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_one_attached :profile_picture
  has_many :tasks, dependent: :destroy
  has_many :offers, foreign_key: 'service_provider_id', dependent: :destroy
  has_many :sent_messages, class_name: "Message", foreign_key: "sender_id", dependent: :destroy
  has_many :received_messages, class_name: "Message", foreign_key: "receiver_id", dependent: :destroy
  
  enum user_type: { 
    customer: 'customer', 
    service_provider: 'service_provider', 
    admin: 'admin' 
  }

  # Validations
  validates :first_name, :last_name, presence: true, length: { minimum: 2 }
  validates :phone, presence: true, uniqueness: true,
            format: { with: /\A(\+63|0)[0-9]{10}\z/, message: "must be valid PH format" }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :user_type, inclusion: { in: user_types.keys }
  validates :service_radius_km, numericality: { greater_than: 0, less_than: 101 }, 
            if: :service_provider?
  validates :rating, numericality: { in: 0.0..5.0 }, allow_nil: true

  # Scopes
  scope :verified, -> { where(verified: true) }
  scope :providers, -> { where(user_type: 'service_provider') }
  scope :customers, -> { where(user_type: 'customer') }
  scope :near_location, ->(lat, lng, radius = 20) {
    where("ST_DWithin(ST_MakePoint(longitude, latitude), ST_MakePoint(?, ?), ?)", 
          lng, lat, radius * 1000)
  }

  SENSITIVE_FIELDS = [:user_type, :verified]

  def soft_delete
    self.skip_reconfirmation!
    update(
      deleted_at: Time.current,
      first_name: "Deleted",
      last_name: "User",
      email: scrubbed_email
    )
  end

  def deleted?
    deleted_at.present?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def can_provide_services?
    service_provider? && active? && verified?
  end

  def self.permitted_fields(is_admin: false)
    base = [:email, :first_name, :last_name, :profile_picture, :age,
            :longitude, :latitude, :location, :bio, :phone]
    is_admin ? base + SENSITIVE_FIELDS : base
  end

  private

  def scrubbed_email
    "deleted_user_#{id}@deleted.com"
  end

  def prevent_admin_signup
    if user_type == "admin"
      errors.add(:user_type, "cannot be admin")
      throw(:abort)
    end
  end
end
