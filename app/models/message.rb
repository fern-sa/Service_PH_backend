class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"
  belongs_to :offer

  has_many_attached :message_images

  validates :body, presence: true

  # Scope for chronological order
  scope :chronological, -> { order(created_at: :asc) }

  # Class method to fetch messages for an offer
  def self.fetch_log(offer_id)
    where(offer_id: offer_id).chronological
  end
end
