# Clear existing data
puts "🧹 Clearing existing data..."
User.destroy_all
Category.destroy_all
Task.destroy_all
Offer.destroy_all
Payment.destroy_all

puts "👥 Creating users..."

# Create customers
customers = [
  {
    email: "customer1@test.com",
    password: "password123",
    first_name: "Maria",
    last_name: "Santos",
    user_type: "customer",
    location: "Makati City, Metro Manila",
    city: "Makati",
    province: "Metro Manila",
    latitude: 14.5547,
    longitude: 121.0244,
    phone: "09171234567",
    verified: true,
    active: true
  },
  {
    email: "customer2@test.com",
    password: "password123",
    first_name: "Juan",
    last_name: "Dela Cruz",
    user_type: "customer",
    location: "Quezon City, Metro Manila",
    city: "Quezon City",
    province: "Metro Manila",
    latitude: 14.6760,
    longitude: 121.0437,
    phone: "09181234567",
    verified: true,
    active: true
  },
  {
    email: "customer3@test.com",
    password: "password123",
    first_name: "Ana",
    last_name: "Garcia",
    user_type: "customer",
    location: "Taguig City, Metro Manila",
    city: "Taguig",
    province: "Metro Manila",
    latitude: 14.5176,
    longitude: 121.0509,
    phone: "09191234567",
    verified: true,
    active: true
  }
]

customers.each do |customer_data|
  user = User.create!(customer_data)
  puts "✅ Created customer: #{user.email}"
end

# Create service providers
service_providers = [
  {
    email: "provider1@test.com",
    password: "password123",
    first_name: "Carlos",
    last_name: "Reyes",
    user_type: "service_provider",
    location: "Manila City, Metro Manila",
    city: "Manila",
    province: "Metro Manila",
    latitude: 14.5995,
    longitude: 120.9842,
    phone: "09201234567",
    bio: "Professional plumber with 10 years experience. Licensed and insured.",
    rating: 4.8,
    total_reviews: 25,
    service_radius_km: 15,
    verified: true,
    active: true
  },
  {
    email: "provider2@test.com",
    password: "password123",
    first_name: "Elena",
    last_name: "Martinez",
    user_type: "service_provider",
    location: "Pasig City, Metro Manila",
    city: "Pasig",
    province: "Metro Manila",
    latitude: 14.5764,
    longitude: 121.0851,
    phone: "09211234567",
    bio: "Certified electrician specializing in residential and commercial work.",
    rating: 4.9,
    total_reviews: 18,
    service_radius_km: 20,
    verified: true,
    active: true
  },
  {
    email: "provider3@test.com",
    password: "password123",
    first_name: "Miguel",
    last_name: "Torres",
    user_type: "service_provider",
    location: "San Juan City, Metro Manila",
    city: "San Juan",
    province: "Metro Manila",
    latitude: 14.6019,
    longitude: 121.0355,
    phone: "09221234567",
    bio: "House cleaning specialist with eco-friendly products. 5 years experience.",
    rating: 4.7,
    total_reviews: 32,
    service_radius_km: 25,
    verified: true,
    active: true
  },
  {
    email: "provider4@test.com",
    password: "password123",
    first_name: "Lisa",
    last_name: "Chen",
    user_type: "service_provider",
    location: "Mandaluyong City, Metro Manila",
    city: "Mandaluyong",
    province: "Metro Manila",
    latitude: 14.5832,
    longitude: 121.0409,
    phone: "09231234567",
    bio: "AC repair and maintenance expert. Available 24/7 for emergency calls.",
    rating: 4.6,
    total_reviews: 15,
    service_radius_km: 18,
    verified: true,
    active: true
  }
]

service_providers.each do |provider_data|
  user = User.create!(provider_data)
  puts "✅ Created service provider: #{user.email}"
end

puts "📂 Creating categories..."

categories = [
  {
    name: "Plumbing",
    description: "Pipe repairs, leak fixing, installation services",
    icon: "🔧",
    sort_order: 1,
    active: true
  },
  {
    name: "Electrical",
    description: "Wiring, electrical repairs, installation services", 
    icon: "⚡",
    sort_order: 2,
    active: true
  },
  {
    name: "Cleaning",
    description: "House cleaning, deep cleaning, maintenance cleaning",
    icon: "🧹",
    sort_order: 3,
    active: true
  },
  {
    name: "AC Repair",
    description: "Air conditioning repair, maintenance, installation",
    icon: "❄️",
    sort_order: 4,
    active: true
  },
  {
    name: "Gardening",
    description: "Landscaping, lawn care, plant maintenance",
    icon: "🌱",
    sort_order: 5,
    active: true
  }
]

categories.each do |category_data|
  category = Category.create!(category_data)
  puts "✅ Created category: #{category.name}"
end

puts "📋 Creating tasks..."

# Get users and categories for task creation
customers = User.where(user_type: 'customer')
plumbing_category = Category.find_by(name: 'Plumbing')
electrical_category = Category.find_by(name: 'Electrical')
cleaning_category = Category.find_by(name: 'Cleaning')
ac_category = Category.find_by(name: 'AC Repair')

tasks = [
  {
    user: customers[0],
    category: plumbing_category,
    title: "Kitchen Sink Leak Repair",
    description: "My kitchen sink has been leaking under the cabinet for the past week. The leak seems to be coming from the pipe connections. Need urgent repair as it's causing water damage.",
    budget_min: 1500.00,
    budget_max: 3000.00,
    location: "Makati City, Metro Manila",
    city: "Makati",
    province: "Metro Manila",
    latitude: 14.5547,
    longitude: 121.0244,
    preferred_date: 1.day.from_now,
    status: "open"
  },
  {
    user: customers[1],
    category: electrical_category,
    title: "Power Outlet Installation",
    description: "Need to install 3 additional power outlets in my home office. The location is already planned and I have the materials ready.",
    budget_min: 2000.00,
    budget_max: 4000.00,
    location: "Quezon City, Metro Manila",
    city: "Quezon City",
    province: "Metro Manila",
    latitude: 14.6760,
    longitude: 121.0437,
    preferred_date: 2.days.from_now,
    status: "open"
  },
  {
    user: customers[2],
    category: cleaning_category,
    title: "Deep Cleaning Service",
    description: "Moving into a new apartment and need deep cleaning service. 2-bedroom apartment, approximately 60 sqm. Includes kitchen, bathroom, and all rooms.",
    budget_min: 3000.00,
    budget_max: 5000.00,
    location: "Taguig City, Metro Manila",
    city: "Taguig",
    province: "Metro Manila",
    latitude: 14.5176,
    longitude: 121.0509,
    preferred_date: 3.days.from_now,
    status: "open"
  },
  {
    user: customers[0],
    category: ac_category,
    title: "AC Unit Not Cooling",
    description: "My split-type AC unit is not cooling properly. It's running but only blowing warm air. Might need cleaning or refrigerant refill.",
    budget_min: 2500.00,
    budget_max: 6000.00,
    location: "Makati City, Metro Manila",
    city: "Makati",
    province: "Metro Manila", 
    latitude: 14.5547,
    longitude: 121.0244,
    preferred_date: 1.day.from_now,
    status: "open"
  },
  {
    user: customers[1],
    category: plumbing_category,
    title: "Bathroom Faucet Replacement",
    description: "Old bathroom faucet is broken and needs replacement. I already bought the new faucet, just need professional installation.",
    budget_min: 1000.00,
    budget_max: 2500.00,
    location: "Quezon City, Metro Manila",
    city: "Quezon City",
    province: "Metro Manila",
    latitude: 14.6760,
    longitude: 121.0437,
    preferred_date: 4.days.from_now,
    status: "open"
  }
]

tasks.each do |task_data|
  task = Task.create!(task_data)
  puts "✅ Created task: #{task.title}"
end

puts "💼 Creating offers..."

# Get service providers and tasks
providers = User.where(user_type: 'service_provider')
all_tasks = Task.all

# Create offers for testing different payment scenarios
offers_data = [
  # Online payment offers
  {
    task: all_tasks[0], # Kitchen Sink Leak
    service_provider: providers[0], # Carlos (Plumber)
    price: 2500.00,
    message: "I can fix your kitchen sink leak today. I have 10 years experience and all necessary tools. The leak sounds like a simple pipe connection issue that I can resolve quickly.",
    availability_date: 4.hours.from_now,
    payment_method: "online",
    terms: "Payment will be held in escrow until job completion. Includes 30-day warranty on repair work."
  },
  {
    task: all_tasks[1], # Power Outlet Installation  
    service_provider: providers[1], # Elena (Electrician)
    price: 3200.00,
    message: "Licensed electrician available for your outlet installation. I can complete all 3 outlets in one visit with proper safety compliance and testing.",
    availability_date: 6.hours.from_now,
    payment_method: "online",
    terms: "Online payment secured until completion. All work complies with electrical codes."
  },
  
  # Cash payment offers
  {
    task: all_tasks[2], # Deep Cleaning
    service_provider: providers[2], # Miguel (Cleaner)
    price: 4000.00,
    message: "Professional deep cleaning service with eco-friendly products. I'll bring all equipment and supplies needed for your 2-bedroom apartment.",
    availability_date: 8.hours.from_now,
    payment_method: "cash",
    terms: "Cash payment upon completion. Includes all cleaning supplies and 100% satisfaction guarantee."
  },
  {
    task: all_tasks[3], # AC Repair
    service_provider: providers[3], # Lisa (AC Expert)
    price: 4500.00,
    message: "AC specialist available for diagnosis and repair. Common issue with split-type units. I'll diagnose first and provide exact quote before proceeding.",
    availability_date: 2.hours.from_now,
    payment_method: "cash",
    terms: "Cash payment after service completion. Free diagnosis, pay only if you approve the repair."
  },
  
  # Additional offers for comparison testing
  {
    task: all_tasks[0], # Kitchen Sink - Second offer
    service_provider: providers[2], # Miguel (alternative provider)
    price: 2800.00,
    message: "I also do plumbing repairs alongside cleaning services. Can fix your sink leak with quality materials and workmanship.",
    availability_date: 12.hours.from_now,
    payment_method: "cash",
    terms: "Cash payment on completion. 6-month warranty on all repairs."
  },
  {
    task: all_tasks[4], # Bathroom Faucet
    service_provider: providers[0], # Carlos (Plumber)
    price: 1500.00,
    message: "Quick faucet installation service. Since you already have the faucet, this will be a straightforward installation job.",
    availability_date: 10.hours.from_now,
    payment_method: "online",
    terms: "Secure online payment. Professional installation with proper sealing."
  }
]

offers_data.each do |offer_data|
  offer = Offer.create!(offer_data)
  puts "✅ Created offer: #{offer.service_provider.first_name} for #{offer.task.title} (#{offer.payment_method})"
end

puts "\n🎯 Seed data summary:"
puts "#{User.count} users created (#{User.where(user_type: 'customer').count} customers, #{User.where(user_type: 'service_provider').count} providers)"
puts "#{Category.count} categories created"
puts "#{Task.count} tasks created"  
puts "#{Offer.count} offers created (#{Offer.where(payment_method: 'online').count} online, #{Offer.where(payment_method: 'cash').count} cash)"

puts "\n📧 Test Credentials:"
puts "Customers:"
puts "  - customer1@test.com / password123 (Maria Santos - has plumbing & AC tasks)"
puts "  - customer2@test.com / password123 (Juan Dela Cruz - has electrical & plumbing tasks)" 
puts "  - customer3@test.com / password123 (Ana Garcia - has cleaning task)"

puts "\nService Providers:"
puts "  - provider1@test.com / password123 (Carlos - Plumber)"
puts "  - provider2@test.com / password123 (Elena - Electrician)"
puts "  - provider3@test.com / password123 (Miguel - Cleaner)" 
puts "  - provider4@test.com / password123 (Lisa - AC Repair)"

puts "\n💡 Payment Testing Scenarios Available:"
puts "  - Online payment offers: Kitchen sink, Power outlets, Bathroom faucet"
puts "  - Cash payment offers: Deep cleaning, AC repair, Alternative sink repair"
puts "  - Multiple offers per task for comparison testing"

puts "\n✅ Database seeded successfully! Ready for comprehensive payment testing."
