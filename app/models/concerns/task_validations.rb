module TaskValidations
  extend ActiveSupport::Concern

  included do
    validates :title, presence: true, length: { minimum: 5, maximum: 100 }
    validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
    validates :location, presence: true
    validates :budget_min, :budget_max, presence: true, 
              numericality: { greater_than: 0 }
    validates :preferred_date, presence: true
    
    validate :budget_max_greater_than_min
    validate :preferred_date_not_in_past
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