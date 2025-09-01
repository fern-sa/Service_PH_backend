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
    @users = User.all
    render json: UserSerializer.new(@users).serializable_hash, status: :ok
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
    if params[:user][:id].present? 
        @user = User.find_by(id: params[:user][:id])
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

  private

  def user_update_params
    params.require(:user).permit(:email, :first_name, :last_name, :profile_picture, :age, :longitude, :latitude, :location, :bio, :phone)
  end

  def check_if_admin_or_current_user
    return @user = current_user if !params[:user][:id].present?
    if current_user.admin? && params[:user][:id].present?
      @user = User.find_by(id: params[:user][:id])
      render json: { error: "User not found" }, status: :not_found and return if @user == nil
      return @user
    elsif !current_user.admin? && params[:user][:id].present?
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
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
