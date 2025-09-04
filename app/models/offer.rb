class Offer < ApplicationRecord
  include OfferValidations
  include OfferStateMachine
  
  belongs_to :task
  belongs_to :service_provider, class_name: 'User'
  has_one :payment, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many_attached :completion_photos
  scope :by_price, -> { order(:price) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user_id) {
    joins(:task)
    .where(tasks: { user_id: user_id })
    .or(Offer.where(service_provider_id: user_id))
  }

  def provider_name
    service_provider.full_name
  end

  def provider_rating
    service_provider.rating
  end

  def as_log
    {
      offer_id: id,
      service_provider_id: service_provider.id,
      service_provider_full_name: service_provider.full_name,
      customer_id: task.user.id,
      customer_full_name: task.user.full_name,
      log: MessageSerializer.new(Message.fetch_log(id)).serializable_hash
    }
  end

  def self.all_logs_in_db
    includes(:task, :messages, :service_provider).map(&:as_log)
  end

  def create_payment!
    return payment if payment.present?
    
    Payment.create!(
      task: task,
      offer: self,
      amount: price,
      payment_method: payment_method
    )
  end

end