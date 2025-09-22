class Users::RegistrationsController < Devise::RegistrationsController
  before_action :redirect_if_authenticated, only: [:new, :create]

  def create
    super
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