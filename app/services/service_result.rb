class ServiceResult
  attr_reader :data, :error_message, :errors, :status

  def initialize(success:, data: nil, error_message: nil, errors: nil, status: nil)
    @success = success
    @data = data
    @error_message = error_message
    @errors = errors
    @status = status
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  def self.success(data = nil)
    new(success: true, data: data)
  end

  def self.failure(error_message:, status: :unprocessable_entity, errors: nil)
    new(
      success: false, 
      error_message: error_message, 
      status: status, 
      errors: errors
    )
  end
end