module OfferStateMachine
  extend ActiveSupport::Concern

  included do
    enum status: {
      pending: 'pending',
      accepted: 'accepted',
      rejected: 'rejected'
    }

    scope :pending, -> { where(status: 'pending') }
    scope :accepted, -> { where(status: 'accepted') }
  end

  def can_be_accepted?
    pending? && task.open?
  end

  def can_start_work?
    accepted? && task.assigned?
  end

  def can_mark_complete?
    accepted? && task.in_progress?
  end
  
  def completed?
    task&.completed?
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
end