class Tasks::CreationService < ApplicationService
  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    create_task
  end

  private

  attr_reader :user, :params

  def create_task
    task = user.tasks.build(params)
    
    if task.save
      success(task)
    else
      failure(
        error_message: "Task couldn't be created: #{task.errors.full_messages.to_sentence}",
        errors: task.errors.full_messages
      )
    end
  end
end