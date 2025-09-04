class Tasks::StatusService < ApplicationService
  def initialize(task:, action:)
    @task = task
    @action = action.to_s
  end

  def call
    case action
    when 'start_work'
      start_work
    when 'mark_complete'
      mark_complete
    else
      failure(error_message: "Unknown action: #{action}")
    end
  end

  private

  attr_reader :task, :action

  def start_work
    unless task.can_start_work?
      return failure(error_message: 'Task cannot be started')
    end

    if task.start_work!
      success(task)
    else
      failure(error_message: 'Failed to start work on task')
    end
  end

  def mark_complete
    unless task.can_be_completed?
      return failure(error_message: 'Task cannot be marked as complete')
    end

    if task.mark_complete!
      success(task)
    else
      failure(error_message: 'Failed to mark task as complete')
    end
  end
end