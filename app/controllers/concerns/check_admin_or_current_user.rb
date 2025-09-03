module CheckAdminOrCurrentUser
  extend ActiveSupport::Concern

  def check_if_admin_or_current_user
    target_user_id = params.dig(:user, :id)
    return @user = current_user if target_user_id.blank?
    
    if current_user.admin? || target_user_id.to_i == current_user.id
      @user = User.find_by(id: target_user_id)
      return render json: { error: "User not found" }, status: :not_found unless @user
    else
      return render json: { error: "Not authorized" }, status: :unauthorized
    end

    @user
  end
end