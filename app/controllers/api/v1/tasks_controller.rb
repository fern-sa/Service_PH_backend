class Api::V1::TasksController < ApplicationController
  include Pagination
  
  before_action :authenticate_user!, except: [:index, :show]
  before_action :find_task, only: [:show, :update, :destroy]
  before_action :authorize_task_owner, only: [:update, :destroy]

  def index
    tasks = Task.includes(:category, :user).available.order(created_at: :desc)
    
    # Apply filters
    tasks = tasks.by_category(params[:category_id]) if params[:category_id].present?
    tasks = apply_budget_filter(tasks) if params[:min_budget].present? || params[:max_budget].present?
    tasks = apply_search_filter(tasks) if params[:search].present?
    
    # Apply pagination
    tasks = paginate_collection(tasks)

    render json: {
      status: { code: 200 },
      data: tasks.map { |task| TaskSerializer.new(task).serializable_hash[:data][:attributes] },
      pagination: pagination_meta(tasks)
    }
  end

  def show
    render json: {
      status: { code: 200 },
      data: TaskSerializer.new(@task).serializable_hash[:data][:attributes]
    }
  end

  def create
    @task = current_user.tasks.build(task_params)

    if @task.save
      render json: {
        status: { code: 201, message: 'Task created successfully' },
        data: TaskSerializer.new(@task).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: {
        status: { message: "Task couldn't be created: #{@task.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      render json: {
        status: { code: 200, message: 'Task updated successfully' },
        data: TaskSerializer.new(@task).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: { message: "Task couldn't be updated: #{@task.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @task.destroy
      render json: {
        status: { code: 200, message: 'Task deleted successfully' }
      }
    else
      render json: { error: 'Failed to delete task' }, status: :unprocessable_entity
    end
  end

  private

  def find_task
    @task = Task.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Task not found' }, status: :not_found
  end

  def task_params
    params.require(:task).permit(
      :category_id, :title, :description, :budget_min, :budget_max,
      :location, :preferred_date, :latitude, :longitude, :city, :province
    )
  end

  def authorize_task_owner
    unless current_user == @task.user || current_user.admin?
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end

  def apply_budget_filter(tasks)
    min_budget = params[:min_budget]&.to_f || 0
    max_budget = params[:max_budget]&.to_f || Float::INFINITY
    tasks.in_budget_range(min_budget, max_budget)
  end

  def apply_search_filter(tasks)
    search_term = "%#{params[:search]}%"
    tasks.where("title ILIKE ? OR description ILIKE ?", search_term, search_term)
  end
end