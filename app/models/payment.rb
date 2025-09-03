class Payment < ApplicationRecord
  belongs_to :task
  belongs_to :offer
  
  enum status: {
    pending: 'pending',
    escrowed: 'escrowed', 
    released: 'released',
    failed: 'failed'
  }
  
  enum payment_method: {
    cash: 'cash',
    online: 'online'  
  }
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, inclusion: { in: payment_methods.keys }
  validates :status, inclusion: { in: statuses.keys }
  
  scope :for_task, ->(task_id) { where(task: task_id) }
  scope :by_status, ->(status) { where(status: status) }
  
  def can_be_released?
    escrowed?
  end
  
  def release!
    return false unless can_be_released?
    update!(status: 'released')
  end
  
  def escrow!
    return false unless pending?
    update!(status: 'escrowed')  
  end
end