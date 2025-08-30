class Task < ApplicationRecord
  include Geocodable

  belongs_to :user
  belongs_to :category
  # TODO: Add offers relationship when Offer model is created
  # has_many :offers, dependent: :destroy
  # belongs_to :assigned_offer, class_name: 'Offer', optional: true

  # Enums for status
  enum status: {
    open: 'open',
    assigned: 'assigned', 
    in_progress: 'in_progress',
    completed: 'completed',
    cancelled: 'cancelled'
  }

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :location, presence: true
  validates :budget_min, :budget_max, presence: true, 
            numericality: { greater_than: 0 }
  validate :budget_max_greater_than_min
  validates :preferred_date, presence: true
  validate :preferred_date_not_in_past

  scope :available, -> { where(status: 'open') }
  scope :near_location, ->(lat, lng, radius = 20) {
    near([lat, lng], radius)
  }
  scope :in_budget_range, ->(min, max) {
    where('budget_min <= ? AND budget_max >= ?', max, min)
  }
  scope :by_category, ->(category_id) { where(category: category_id) }

  def budget_range
    return "₱#{budget_min}" if budget_min == budget_max
    "₱#{budget_min} - ₱#{budget_max}"
  end

  def can_receive_offers?
    open?
  end

  # TODO: Add offer-related methods when Offer model is created
  # def assign_to_offer!(offer)
  # def assigned_service_provider
  # etc.

  def self.inactive_statuses
    ['completed', 'cancelled']
  end

  private

  def budget_max_greater_than_min
    return unless budget_min.present? && budget_max.present?
    
    if budget_max < budget_min
      errors.add(:budget_max, "must be greater than or equal to minimum budget")
    end
  end

  def preferred_date_not_in_past
    return unless preferred_date.present?
    
    if preferred_date < Time.current
      errors.add(:preferred_date, "cannot be in the past")
    end
  end
end