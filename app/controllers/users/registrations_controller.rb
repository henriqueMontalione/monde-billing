class Users::RegistrationsController < Devise::RegistrationsController
  before_action :redirect_if_authenticated, only: [:new, :create]

  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        sign_up(resource_name, resource)

        respond_to do |format|
          format.turbo_stream { render :create }
          format.html {
            flash[:notice] = "Bem-vindo! Você se registrou com sucesso."
            redirect_to after_sign_up_path_for(resource)
          }
        end
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def after_sign_up_path_for(resource)
    root_path
  end

  def after_inactive_sign_up_path_for(resource)
    root_path
  end

  private

  def redirect_if_authenticated
    if user_signed_in?
      redirect_to root_path, notice: 'Você já está logado.'
    end
  end
end