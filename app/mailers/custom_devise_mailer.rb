class CustomDeviseMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'

  def reset_password_instructions(record, token, opts = {})
    @frontend_url = "#{ENV['FRONTEND_URL']}/reset-password?reset_password_token=#{token}"
    super
  end
end