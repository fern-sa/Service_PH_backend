module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  end

  private

  def handle_not_found(exception)
    resource_name = exception.model.constantize.model_name.human
    render_not_found(resource: resource_name)
  end

  def handle_validation_error(exception)
    render_error(
      message: "Validation failed: #{exception.record.errors.full_messages.to_sentence}",
      status: :unprocessable_entity
    )
  end

  def handle_parameter_missing(exception)
    render_error(
      message: "Missing required parameter: #{exception.param}",
      status: :bad_request
    )
  end

  def handle_service_error(result)
    return unless result.failure?
    
    render_error(
      message: result.error_message,
      status: result.status || :unprocessable_entity,
      details: result.errors
    )
  end
end