class ApplicationService
  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end

  protected

  def success(data = nil)
    ServiceResult.success(data)
  end

  def failure(error_message:, status: :unprocessable_entity, errors: nil)
    ServiceResult.failure(
      error_message: error_message,
      status: status,
      errors: errors
    )
  end
end