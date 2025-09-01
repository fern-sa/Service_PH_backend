class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :first_name, :last_name, :user_type, :location, :longitude, :latitude, :age, :phone, :total_reviews, :rating, :bio, :confirmed_at, :sign_in_count, :created_at, :last_sign_in_at

  attribute :profile_picture_url do |user|
    user.profile_picture.attached? ? Rails.application.routes.url_helpers.url_for(user.profile_picture) : nil
  end

  attribute :full_name do |user|
    user.full_name
  end

  # Dashboard stats - conditionally included
  attribute :dashboard_stats, if: Proc.new { |record, params| 
    params && params[:include_stats] == true 
  } do |user|
    if user.customer?
      # Customer dashboard stats
      tasks = user.tasks.includes(:offers)
      {
        total_tasks: tasks.count,
        open_tasks: tasks.where(status: 'open').count,
        assigned_tasks: tasks.where(status: 'assigned').count,
        in_progress_tasks: tasks.where(status: 'in_progress').count,
        completed_tasks: tasks.where(status: 'completed').count,
        pending_offers_count: tasks.joins(:offers).where(offers: { status: 'pending' }).count
      }
    elsif user.service_provider?
      # Service provider dashboard stats
      offers = user.offers.includes(:task)
      accepted_offers = offers.where(status: 'accepted')
      {
        total_offers: offers.count,
        pending_offers: offers.where(status: 'pending').count,
        accepted_offers: accepted_offers.count,
        active_jobs: user.tasks.joins(:offers).where(
          status: 'in_progress',
          offers: { service_provider_id: user.id, status: 'accepted' }
        ).count,
        completed_jobs: user.tasks.joins(:offers).where(
          status: 'completed',
          offers: { service_provider_id: user.id, status: 'accepted' }
        ).count,
        total_earnings: accepted_offers.joins(:task).where(tasks: { status: 'completed' }).sum(:price)
      }
    else
      {}
    end
  end

  # Recent tasks for customers
  attribute :recent_tasks, if: Proc.new { |record, params| 
    params && params[:include_stats] == true && record.customer?
  } do |user|
    user.tasks.includes(:category, :offers)
        .order(created_at: :desc)
        .limit(5)
        .map do |task|
      {
        id: task.id,
        title: task.title,
        status: task.status,
        budget_min: task.budget_min,
        budget_max: task.budget_max,
        created_at: task.created_at,
        category: {
          id: task.category.id,
          name: task.category.name,
          icon: task.category.icon
        },
        offers_count: task.offers.count
      }
    end
  end

  # Recent offers for service providers
  attribute :recent_offers, if: Proc.new { |record, params| 
    params && params[:include_stats] == true && record.service_provider?
  } do |user|
    user.offers.includes(task: [:category, :user])
        .order(created_at: :desc)
        .limit(5)
        .map do |offer|
      {
        id: offer.id,
        price: offer.price,
        status: offer.status,
        created_at: offer.created_at,
        task: {
          id: offer.task.id,
          title: offer.task.title,
          status: offer.task.status,
          budget_min: offer.task.budget_min,
          budget_max: offer.task.budget_max,
          user: {
            id: offer.task.user.id,
            full_name: offer.task.user.full_name
          }
        }
      }
    end
  end

  # Available tasks nearby (for service providers)
  attribute :available_tasks, if: Proc.new { |record, params| 
    params && params[:include_stats] == true && record.service_provider? && record.latitude && record.longitude
  } do |user|
    Task.where(status: 'open')
        .includes(:category, :user)
        .limit(10)
        .map do |task|
      {
        id: task.id,
        title: task.title,
        budget_min: task.budget_min,
        budget_max: task.budget_max,
        location: task.location,
        preferred_date: task.preferred_date,
        created_at: task.created_at,
        category: {
          id: task.category.id,
          name: task.category.name,
          icon: task.category.icon
        },
        user: {
          id: task.user.id,
          full_name: task.user.full_name
        }
      }
    end
  end
end
