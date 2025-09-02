# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionsFix
  respond_to :json
  before_action :authenticate_user!, only: [:destroy, :update, :show, :index]

  def destroy
    return if !check_if_admin_or_current_user
    if @user.destroy
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
    if id_param.present? 
      @user = User.find_by(id: id_param)
      render json: { error: "User not found" }, status: :not_found and return unless @user
    else
      @user = current_user
    end
    serialize_and_santize
    render json: {
      status: {code: 200},
      data: @user_serialized
    }
  end

  private

  def id_param
      params.dig(:user, :id)
  end

  def serialize_and_santize
    @user_serialized = UserSerializer.new(@user).serializable_hash[:data][:attributes]
    @user_serialized = @user_serialized.except(:location, :longitude, :latitude, :age, :phone, :email, :sign_in_count) if !current_user.admin?
  end

  def user_update_params
    params.require(:user).permit(:email, :first_name, :last_name, :profile_picture, :age, :longitude, :latitude, :location, :bio, :phone)
  end

  def check_if_admin_or_current_user
    return @user = current_user if !id_param.present?
    if current_user.admin? && id_param.present?
      @user = User.find_by(id: id_param)
      render json: { error: "User not found" }, status: :not_found and return if @user == nil
      return @user
    elsif !current_user.admin? && id_param.present?
      render json: { error: "Not authorized"}, status: :unauthorized
      return
    end
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
