module SetDeviseMapping
  extend ActiveSupport::Concern

  included do
    prepend_before_action :set_devise_mapping
  end

  def set_devise_mapping
    Rails.logger.info "Running in #{controller_name}##{action_name}"

    Devise.mappings[:user] = Devise.mappings[:api_v1_user]
    request.env['devise.mapping'] = Devise.mappings[:user]
    warden.config[:default_strategies][:user] =  warden.config[:default_strategies].delete(:api_v1_user)
  end

end