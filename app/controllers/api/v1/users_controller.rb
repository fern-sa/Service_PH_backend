class Api::V1::UsersController < ApplicationController
  include CheckAdminOrCurrentUser
  respond_to :json
  before_action :authenticate_user!, only: [:show, :index]

  def index
    render json: { error: "Not authorized" }, status: :unauthorized and return if !current_user.admin?
    render json: UserSerializer.new(User.all, is_collection: true).serializable_hash, status: :ok
  end

  def show
    render json: { error: "Authentication required" }, status: :unauthorized and return if !current_user
    
    if target_user_id.present? 
        @user = User.find_by(id: target_user_id)
        return render json: { error: "User not found" }, status: :not_found unless @user
      else
        @user = current_user
    end

    include_stats = params[:include_stats] == 'true'
    serializer_params = include_stats ? { include_stats: true } : {}

    render json: {
        status: {code: 200},
        data: UserSerializer.new(@user, { params: serializer_params }).serializable_hash[:data][:attributes]
      }
  end
end