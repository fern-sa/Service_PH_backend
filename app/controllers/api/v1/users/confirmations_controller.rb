# frozen_string_literal: true

class Api::V1::Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      redirect_to "#{ENV['FRONTEND_URL']}/email-confirmed?success=true", allow_other_host: true
    else
      redirect_to "#{ENV['FRONTEND_URL']}/email-confirmed?success=false", allow_other_host: true
    end
  end

  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)

    if successfully_sent?(resource)
      render json: { message: "Confirmation instructions sent to #{resource.email}" }, status: :ok
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

end
