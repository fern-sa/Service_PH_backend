class Category < ApplicationRecord
  validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 50 }
  validates :sort_order, numericality: { greater_than_or_equal_to: 0 }

  has_many :tasks, dependent: :destroy

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:sort_order, :name) }

  def task_count
    tasks.count
  end
end