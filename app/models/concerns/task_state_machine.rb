module TaskStateMachine
  extend ActiveSupport::Concern

  included do
    enum status: {
      open: 'open',
      assigned: 'assigned', 
      in_progress: 'in_progress',
      completed: 'completed',
      cancelled: 'cancelled'
    }

    scope :available, -> { where(status: 'open') }
  end

  def can_receive_offers?
    open?
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
      
      assigned_offer.update!(
        completion_notes: completion_notes,
        completed_at: Time.current
      )
    end
    
    true
  end

  def assign_to_offer!(offer)
    return false unless can_receive_offers?
    return false unless offer.can_be_accepted?
    
    transaction do
      offer.update_columns(
        status: 'accepted',
        accepted_at: Time.current
      )
      
      update_columns(
        status: 'assigned',
        assigned_offer_id: offer.id,
        final_price: offer.price
      )
      
      offers.where.not(id: offer.id).update_all(
        status: 'rejected',
        rejected_at: Time.current
      )
    end
    
    true
  end

  module ClassMethods
    def inactive_statuses
      ['completed', 'cancelled']
    end
  end
end