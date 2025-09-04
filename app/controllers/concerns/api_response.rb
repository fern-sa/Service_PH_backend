module ApiResponse
  extend ActiveSupport::Concern

  private

  def render_success(data: nil, message: nil, status: :ok)
    response_hash = { status: { code: response_code(status) } }
    response_hash[:status][:message] = message if message
    response_hash[:data] = data if data
    
    render json: response_hash, status: status
  end

  def render_error(message:, status: :unprocessable_entity, details: nil)
    response_hash = { 
      status: { 
        code: response_code(status),
        message: message 
      } 
    }
    response_hash[:status][:details] = details if details
    
    render json: response_hash, status: status
  end

  def render_created(data:, message: 'Created successfully')
    render_success(data: data, message: message, status: :created)
  end

  def render_not_found(resource: 'Resource')
    render_error(message: "#{resource} not found", status: :not_found)
  end

  def render_unauthorized(message: 'Not authorized')
    render_error(message: message, status: :forbidden)
  end

  def response_code(status)
    case status
    when :ok then 200
    when :created then 201
    when :unprocessable_entity then 422
    when :not_found then 404
    when :forbidden then 403
    when :payment_required then 402
    else 500
    end
  end
end