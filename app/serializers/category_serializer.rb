class CategorySerializer
  include JSONAPI::Serializer
  attributes :id, :name, :description, :icon, :sort_order, :active, :created_at, :updated_at

  attribute :task_count do |category|
    category.task_count
  end
end