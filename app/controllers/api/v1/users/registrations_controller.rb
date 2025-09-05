# frozen_string_literal: true

class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionsFix
  include SetDeviseMapping
  include CheckAdminOrCurrentUser
  respond_to :json
  before_action :authenticate_user!, only: [:destroy, :update]

  def destroy
    return if !check_if_admin_or_current_user(current_user)
    if @user.soft_delete
      render json: { message: "User account deleted successfully." }, status: :ok
    else
      render json: { error: "Not authorized to delete this account." }, status: :unauthorized
    end
  end

  def update
    return if !check_if_admin_or_current_user(current_user)
    if @user.update(user_update_params)
      render json: { message: "User account updated",
        data: UserSerializer.new(@user).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: { error: "Error",
        details: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def create
    if params.dig(:user, :user_type) == "admin"
      return render json: { error: "You cannot sign up as an admin." }, status: :forbidden
    end

    build_resource(sign_up_params)

    if resource.save
      render json: { message: "Signed up. Please check your email to confirm." }, status: :ok
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_update_params
    permitted = User.permitted_fields(is_admin: current_user&.admin?)
    params.require(:user).permit(permitted)
  end

  def respond_with(current_user, _opts = {})
    if resource.persisted?
      render json: {
        status: {code: 200, message: 'Signed up successfully.'},
        data: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: {message: "User couldn't be created successfully. #{current_user.errors.full_messages.to_sentence}"}
      }, status: :unprocessable_entity
    end

  end
end
