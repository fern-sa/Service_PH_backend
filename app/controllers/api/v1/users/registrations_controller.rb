# frozen_string_literal: true

class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionsFix
  include CheckAdminOrCurrentUser
  respond_to :json
  before_action :authenticate_user!, only: [ :destroy, :update ]
  before_action :configure_sign_up_params, only: [ :create ]

  def destroy
    return if !check_if_admin_or_current_user
    if @user.soft_delete
      render json: { message: "User account deleted successfully." }, status: :ok
    else
      render json: { error: "Not authorized to delete this account." }, status: :unauthorized
    end
  end

  def update
    return if !check_if_admin_or_current_user
    if @user.update(user_update_params)
      render json: {
        message: "User account updated",
        data: UserSerializer.new(@user).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: {
        error: "Error",
        details: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def create
    # Handle both nested and flat parameter structures
    user_params = extract_user_params

    if user_params[:user_type] == "admin"
      return render json: { error: "You cannot sign up as an admin." }, status: :forbidden
    end

    # Manually build the resource with the extracted params
    build_resource(user_params)

    if resource.save
      render json: {
        status: { code: 200, message: "Signed up successfully." },
        data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: {
        status: {
          message: "User couldn't be created successfully.",
          errors: resource.errors.full_messages
        }
      }, status: :unprocessable_entity
    end
  end

  private

  def extract_user_params
    # Check if params are nested under 'user' key or at root level
    if params[:user].present?
      # Standard Devise format: { user: { email: "...", ... } }
      params.require(:user).permit(:email, :password, :password_confirmation,
                                   :first_name, :last_name, :phone, :user_type)
    else
      # Flat format: { email: "...", first_name: "...", ... }
      params.permit(:email, :password, :password_confirmation,
                    :first_name, :last_name, :phone, :user_type)
    end
  end

  def user_update_params
    permitted = User.permitted_fields(is_admin: current_user&.admin?)
    params.require(:user).permit(permitted)
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :last_name, :phone, :user_type
    ])
  end

  def respond_with(current_user, _opts = {})
    if resource.persisted?
      render json: {
        status: { code: 200, message: "Signed up successfully." },
        data: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: {
          message: "User couldn't be created successfully.",
          errors: current_user.errors.full_messages
        }
      }, status: :unprocessable_entity
    end
  end
end
