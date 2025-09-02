class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"
  belongs_to :offer

  has_many_attached :message_images

  validates :body, presence: true
end
