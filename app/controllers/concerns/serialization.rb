module Serialization
  extend ActiveSupport::Concern

  private

  def serialized_offer(offer)
    {
      id: offer.id,
      price: offer.price,
      message: offer.message,
      availability_date: offer.availability_date,
      terms: offer.terms,
      payment_method: offer.payment_method,
      status: offer.status,
      created_at: offer.created_at,
      service_provider: {
        id: offer.service_provider.id,
        name: offer.service_provider.full_name,
        email: offer.service_provider.email
      },
      task: offer.task ? {
        id: offer.task.id,
        title: offer.task.title,
        description: offer.task.description,
        status: offer.task.status,
        location: offer.task.location,
        budget_range: offer.task.budget_range,
        user: {
          id: offer.task.user.id,
          first_name: offer.task.user.first_name,
          last_name: offer.task.user.last_name
        }
      } : nil,
      payment: offer.payment ? {
        id: offer.payment.id,
        status: offer.payment.status,
        stripe_payment_intent_id: offer.payment.stripe_payment_intent_id
      } : nil
    }
  end

  def serialized_offers(offers)
    offers.map { |offer| serialized_offer(offer) }
  end

  def serialized_task(task)
    TaskSerializer.new(task).serializable_hash[:data][:attributes]
  end

  def serialized_tasks(tasks)
    tasks.map { |task| serialized_task(task) }
  end

  def serialized_category(category)
    CategorySerializer.new(category).serializable_hash[:data][:attributes]
  end

  def serialized_categories(categories)
    categories.map { |category| serialized_category(category) }
  end

  def serialized_payment(payment)
    {
      id: payment.id,
      amount: payment.amount,
      payment_method: payment.payment_method,
      status: payment.status,
      stripe_payment_intent_id: payment.stripe_payment_intent_id,
      created_at: payment.created_at,
      offer: {
        id: payment.offer.id,
        price: payment.offer.price,
        status: payment.offer.status
      }
    }
  end

  def task_summary
    return unless @task
    
    {
      id: @task.id,
      title: @task.title,
      description: @task.description,
      budget_min: @task.budget_min,
      budget_max: @task.budget_max,
      budget_range: @task.budget_range,
      status: @task.status,
      location: @task.location
    }
  end
end