class ApplicationController < ActionController::API
  include SetDeviseMapping
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name profile_picture phone age bio location latitude longitude user_type profile_picture])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name profile_picture])
  end

end
