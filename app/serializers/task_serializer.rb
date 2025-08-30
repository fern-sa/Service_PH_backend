class TaskSerializer
  include JSONAPI::Serializer
  attributes :id, :title, :description, :budget_min, :budget_max, :location, 
             :latitude, :longitude, :city, :province, :preferred_date, 
             :status, :completed_at, :final_price, :created_at, :updated_at

  attribute :budget_range do |task|
    task.budget_range
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

  # TODO: Add offer-related attributes when Offer model is created
  # attribute :offers_count do |task|
  #   task.offers.count
  # end
  
  # attribute :assigned_service_provider do |task|
  #   task.assigned_service_provider&.full_name
  # end
end