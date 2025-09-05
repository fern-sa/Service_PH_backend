module CheckAdminOrCurrentUser
  extend ActiveSupport::Concern

  def target_user_id
    params.dig(:user, :id)
  end

  def check_if_admin_or_current_user(current_user)
    return @user = current_user if target_user_id.blank?

    if current_user.admin? || target_user_id.to_i == current_user.id
      @user = User.find_by(id: target_user_id)
      render json: { error: "User not found" }, status: :not_found and return unless @user
    else
      render json: { error: "Not authorized, must be an admin or the user" }, status: :unauthorized and return
    end

    @user
  end
end