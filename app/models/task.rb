class Task < ApplicationRecord
  include Geocodable

  belongs_to :user
  belongs_to :category
  has_many :offers, dependent: :destroy
  belongs_to :assigned_offer, class_name: 'Offer', optional: true

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

  def assign_to_offer!(offer)
    return false unless can_receive_offers?
    return false unless offer.can_be_accepted?
    
    transaction do
      # Update offer status
      offer.update_columns(
        status: 'accepted',
        accepted_at: Time.current
      )
      
      # Update task status and assignment
      update_columns(
        status: 'assigned',
        assigned_offer_id: offer.id
      )
      
      # Reject all other offers
      offers.where.not(id: offer.id).update_all(
        status: 'rejected',
        rejected_at: Time.current
      )
    end
    
    true
  end
  
  def assigned_service_provider
    assigned_offer&.service_provider
  end

  def can_start_work?
    assigned? && assigned_offer.present?
  end

  def can_be_completed?
    in_progress? && assigned_offer.present?
  end

  def start_work!
    return false unless can_start_work?
    
    update!(status: 'in_progress')
    true
  end

  def mark_complete!(completion_notes = nil)
    return false unless can_be_completed?
    
    transaction do
      update!(
        status: 'completed',
        completed_at: Time.current
      )
      
      # Log completion in assigned offer
      assigned_offer.update!(
        completion_notes: completion_notes,
        completed_at: Time.current
      )
    end
    
    true
  end

  def completion_summary
    return nil unless completed?
    
    {
      completed_at: completed_at,
      service_provider: assigned_service_provider&.full_name,
      final_price: final_price,
      completion_notes: assigned_offer&.completion_notes
    }
  end

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