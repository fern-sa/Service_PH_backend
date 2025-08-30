class Offer < ApplicationRecord
  belongs_to :task
  belongs_to :service_provider, class_name: 'User'

  enum status: {
    pending: 'pending',
    accepted: 'accepted',
    rejected: 'rejected'
  }

  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :message, presence: true, length: { minimum: 10, maximum: 500 }
  validates :availability_date, presence: true
  validate :availability_date_not_in_past
  validate :service_provider_can_make_offer, on: :create
  validate :task_can_receive_offers, on: :create
  validates :service_provider_id, uniqueness: { 
    scope: :task_id, 
    message: "can only make one offer per task" 
  }

  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :by_price, -> { order(:price) }
  scope :recent, -> { order(created_at: :desc) }

  def can_be_accepted?
    pending? && task.open?
  end

  def accept!
    return false unless can_be_accepted?
    
    task.assign_to_offer!(self)
  end

  def reject!
    return false unless pending?
    
    update!(
      status: 'rejected',
      rejected_at: Time.current
    )
  end

  def provider_name
    service_provider.full_name
  end

  def provider_rating
    service_provider.rating
  end

  private

  def availability_date_not_in_past
    return unless availability_date.present?
    
    if availability_date < Time.current
      errors.add(:availability_date, "cannot be in the past")
    end
  end

  def service_provider_can_make_offer
    return unless service_provider.present?
    
    unless service_provider.service_provider?
      errors.add(:service_provider, "must be a service provider")
    end
    
    unless service_provider.can_provide_services?
      errors.add(:service_provider, "must be active and verified")
    end
  end

  def task_can_receive_offers
    return unless task.present?
    
    unless task.can_receive_offers?
      errors.add(:task, "is no longer accepting offers")
    end
  end

  def can_start_work?
    accepted? && task.assigned?
  end

  def can_mark_complete?
    accepted? && task.in_progress?
  end
end