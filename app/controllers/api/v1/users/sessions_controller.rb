# frozen_string_literal: true

class Api::V1::Users::SessionsController < Devise::SessionsController
  include SetDeviseMapping
  include RackSessionsFix
  respond_to :json

  def create
    user = warden.authenticate!(auth_options)
    sign_in(:user, user)
    yield user if block_given?
    respond_with(user)
  end

  private

  def respond_with(current_user, _opts = {})
    Rails.logger.info response.headers['Authorization']

    render json: {
      status: { 
        code: 200, message: 'Logged in successfully.',
        data: { user: UserSerializer.new(current_user).serializable_hash[:data][:attributes] }
      }
    }, status: :ok
  end

  def respond_to_on_destroy
    if request.headers['Authorization'].present?
      jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last, ENV['DEVISE_JWT_SECRET_KEY']).first
      current_user = User.find(jwt_payload['sub'])
    end
    
    if current_user
      render json: {
        status: 200,
        message: 'Logged out successfully.'
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
 
end
