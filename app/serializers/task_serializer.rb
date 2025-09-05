class TaskSerializer
  include JSONAPI::Serializer
  attributes :id, :title, :description, :budget_min, :budget_max, :location, 
             :latitude, :longitude, :city, :province, :preferred_date, 
             :status, :completed_at, :final_price, :created_at, :updated_at

  attribute :budget_range do |task|
    task.budget_range
  end

  # Include assigned_offer_id if present
  attribute :assigned_offer_id do |task| 
    task.assigned_offer.id if task.assigned_service_provider.present? 
  end

  # Include category information
  attribute :category do |task|
    {
      id: task.category.id,
      name: task.category.name,
      icon: task.category.icon
    }
  end

  # Include task owner information
  attribute :user do |task|
    {
      id: task.user.id,
      name: task.user.full_name,
      user_type: task.user.user_type
    }
  end

  attribute :offers_count do |task|
    task.offers.count
  end
  
  attribute :assigned_service_provider do |task|
    if task.assigned_service_provider.present?
      {
        id: task.assigned_service_provider.id,
        name: task.assigned_service_provider.full_name,
        rating: task.assigned_service_provider.rating,
        user_type: task.assigned_service_provider.user_type
      }
    end
  end

  attribute :completion_summary do |task|
    task.completion_summary if task.completed?
  end

  attribute :can_start_work do |task|
    task.can_start_work?
  end

  attribute :can_be_completed do |task|
    task.can_be_completed?
  end
end