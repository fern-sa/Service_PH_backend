# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
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

  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
