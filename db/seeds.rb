# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


categories = [
  {
    name: "Plumbing",
    description: "Services related to water, pipes, and drainage systems",
    icon: "🚰",
    sort_order: 1
  },
  {
    name: "Electrical",
    description: "Services for wiring, circuits, and electrical fixtures",
    icon: "💡",
    sort_order: 2
  },
  {
    name: "Carpentry",
    description: "Woodwork, furniture repair, and related services",
    icon: "🪚",
    sort_order: 3
  },
  {
    name: "Cleaning",
    description: "Household and commercial cleaning services",
    icon: "🧹",
    sort_order: 4
  }
]

categories.each do |attrs|
  Category.find_or_create_by!(name: attrs[:name]) do |cat|
    cat.description = attrs[:description]
    cat.icon        = attrs[:icon]
    cat.sort_order  = attrs[:sort_order]
    cat.active      = true
  end
end
