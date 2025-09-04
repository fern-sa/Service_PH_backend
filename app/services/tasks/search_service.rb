class Tasks::SearchService < ApplicationService
  def initialize(params: {})
    @params = params
  end

  def call
    tasks = base_query
    tasks = apply_filters(tasks)
    tasks = apply_ordering(tasks)
    
    success(tasks)
  end

  private

  attr_reader :params

  def base_query
    Task.includes(:category, :user).available
  end

  def apply_filters(tasks)
    tasks = filter_by_category(tasks)
    tasks = filter_by_budget(tasks)
    tasks = filter_by_search(tasks)
    tasks
  end

  def filter_by_category(tasks)
    return tasks unless params[:category_id].present?
    
    tasks.by_category(params[:category_id])
  end

  def filter_by_budget(tasks)
    return tasks unless budget_params_present?
    
    tasks.in_budget_range(
      params[:min_budget] || 0,
      params[:max_budget] || Float::INFINITY
    )
  end

  def filter_by_search(tasks)
    return tasks unless params[:search].present?
    
    search_term = "%#{params[:search]}%"
    tasks.where(
      "title ILIKE ? OR description ILIKE ? OR location ILIKE ?",
      search_term, search_term, search_term
    )
  end

  def apply_ordering(tasks)
    tasks.order(created_at: :desc)
  end

  def budget_params_present?
    params[:min_budget].present? || params[:max_budget].present?
  end
end