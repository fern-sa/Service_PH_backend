class Api::V1::TasksController < ApplicationController
  include Pagination
  include ApiResponse
  include ErrorHandling
  include Serialization
  include Authorization
  
  before_action :authenticate_user!, except: [:index, :show]
  before_action :find_task, only: [:show, :update, :destroy, :start_work, :mark_complete]
  before_action :authorize_task_owner, only: [:update, :destroy]
  before_action :authorize_service_provider_work, only: [:start_work, :mark_complete]

  def index
    result = Tasks::SearchService.call(params: search_params)
    
    if result.success?
      tasks = paginate_collection(result.data)
      render_success(data: {
        tasks: serialized_tasks(tasks),
        pagination: pagination_meta(tasks)
      })
    else
      handle_service_error(result)
    end
  end

  def show
    render_success(data: serialized_task(@task))
  end

  def create
    result = Tasks::CreationService.call(user: current_user, params: task_params)
    
    if result.success?
      render_created(
        data: serialized_task(result.data),
        message: 'Task created successfully'
      )
    else
      handle_service_error(result)
    end
  end

  def update
    if @task.update(task_params)
      render_success(
        data: serialized_task(@task),
        message: 'Task updated successfully'
      )
    else
      render_error(
        message: "Task couldn't be updated: #{@task.errors.full_messages.to_sentence}"
      )
    end
  end

  def destroy
    if @task.destroy
      render_success(message: 'Task deleted successfully')
    else
      render_error(message: 'Failed to delete task')
    end
  end

  def start_work
    result = Tasks::StatusService.call(task: @task, action: 'start_work')
    
    if result.success?
      render_success(
        data: serialized_task(result.data),
        message: 'Work started on task'
      )
    else
      handle_service_error(result)
    end
  end

  def mark_complete
    result = Tasks::CompletionService.call(task: @task, params: params)
    
    if result.success?
      render_success(
        data: serialized_task(result.data),
        message: 'Task marked as completed'
      )
    else
      handle_service_error(result)
    end
  end

  private

  def find_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(
      :category_id, :title, :description, :budget_min, :budget_max,
      :location, :preferred_date, :latitude, :longitude, :city, :province
    )
  end

  def search_params
    params.permit(:category_id, :min_budget, :max_budget, :search)
  end
end