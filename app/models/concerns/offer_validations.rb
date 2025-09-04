module OfferValidations
  extend ActiveSupport::Concern

  included do
    validates :price, presence: true, numericality: { greater_than: 0 }
    validates :message, presence: true, length: { minimum: 10, maximum: 500 }
    validates :availability_date, presence: true
    validates :payment_method, inclusion: { in: %w[cash online] }
    validates :service_provider_id, uniqueness: { 
      scope: :task_id, 
      message: "can only make one offer per task" 
    }
    
    validate :availability_date_not_in_past
    validate :service_provider_can_make_offer, on: :create
    validate :task_can_receive_offers, on: :create
    validate :completion_photos_required, if: :completed?
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

  def completion_photos_required
    if task&.completed? && completion_photos.blank?
      errors.add(:completion_photos, "are required when marking task as complete")
    end
  end
end