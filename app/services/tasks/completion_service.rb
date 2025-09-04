class Tasks::CompletionService < ApplicationService
  def initialize(task:, params:)
    @task = task
    @params = params
  end

  def call
    validate_completion
    complete_task_with_photos
  end

  private

  attr_reader :task, :params

  def validate_completion
    unless task.can_be_completed?
      return failure(error_message: 'Task cannot be completed')
    end

    unless params[:completion_photos].present?
      return failure(error_message: 'Completion photos are required')
    end
  end

  def complete_task_with_photos
    ActiveRecord::Base.transaction do
      attach_completion_photos
      mark_task_complete
      release_payment_if_needed
      success(task.reload)
    end
  rescue => e
    failure(error_message: "Failed to complete task: #{e.message}")
  end

  def attach_completion_photos
    task.assigned_offer.completion_photos.attach(params[:completion_photos])
  end

  def mark_task_complete
    completion_notes = params[:completion_notes]
    unless task.mark_complete!(completion_notes)
      raise ActiveRecord::Rollback
    end
  end

  def release_payment_if_needed
    payment = task.assigned_offer.payment
    if payment&.online? && payment.escrowed?
      payment.release!
    end
  end
end