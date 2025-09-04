module Authorization
  extend ActiveSupport::Concern

  private

  def authorize_service_provider
    unless current_user.service_provider?
      render_error(message: 'Only service providers can make offers', status: :forbidden)
    end
  end

  def authorize_task_owner
    unless current_user == @task.user || current_user.admin?
      render_error(message: 'Not authorized', status: :forbidden)
    end
  end

  def authorize_offer_access
    return if current_user == @task.user
    
    if current_user.service_provider? && @offer.service_provider == current_user
      return
    end
    
    render_error(message: 'Not authorized', status: :forbidden)
  end

  def authorize_service_provider_work
    unless current_user == @task.assigned_service_provider
      render_error(message: 'Not authorized', status: :forbidden)
    end
  end

  def authorize_payment_access
    return if current_user == @offer.task.user
    
    if current_user.service_provider? && @offer.service_provider == current_user
      return
    end
    
    render_error(message: 'Not authorized', status: :forbidden)
  end
end