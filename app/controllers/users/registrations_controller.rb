# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionsFix
  include CheckAdminOrCurrentUser
  respond_to :json
  before_action :authenticate_user!, only: [:destroy, :update, :show, :index]

  def destroy
    return if !check_if_admin_or_current_user
    if @user.soft_delete
      render json: { message: "User account deleted successfully." }, status: :ok
    else
      render json: { error: "Not authorized to delete this account." }, status: :unauthorized
    end
  end

  def index
    render json: { error: "Not authorized" }, status: :unauthorized and return if !current_user.admin?
    render json: UserSerializer.new(User.all).serializable_hash, status: :ok
  end

  def update
    return if !check_if_admin_or_current_user
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

  def show
    unless current_user
      render json: { error: "Authentication required" }, status: :unauthorized and return
    end

    if target_user_id.present? 
        @user = User.find_by(id: target_user_id)
        render json: { error: "User not found" }, status: :not_found and return if @user == nil
      else
        @user = current_user
    end

    # Check if dashboard stats should be included
    include_stats = params[:include_stats] == 'true'
    serializer_params = include_stats ? { include_stats: true } : {}

    render json: {
        status: {code: 200},
        data: UserSerializer.new(@user, { params: serializer_params }).serializable_hash[:data][:attributes]
      }
  end

  def create
    if params.dig(:user, :user_type) == "admin"
      return render json: { error: "You cannot sign up as an admin." }, status: :forbidden
    end

    super
  end

  private

  def user_update_params
    permitted = [:email, :first_name, :last_name, :profile_picture, :age, :longitude, :latitude, :location, :bio, :phone]
    permitted << :user_type if current_user&.admin?
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
