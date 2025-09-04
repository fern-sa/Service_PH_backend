class Task < ApplicationRecord
  include Geocodable
  include TaskValidations
  include TaskStateMachine

  belongs_to :user
  belongs_to :category
  has_many :offers, dependent: :destroy
  belongs_to :assigned_offer, class_name: 'Offer', optional: true

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

  def assigned_service_provider
    assigned_offer&.service_provider
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

end