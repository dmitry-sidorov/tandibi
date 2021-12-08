class ApplicationController < ActionController::Base
  layout :layout_by_resource
  before_action :configure_devise_params, if: :devise_controller?

  protected
  def configure_devise_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name,
      :last_name,
      :username,
      :email,
      :password,
      :password_confirmation
    ])
  end

  private
  def layout_by_resource
    devise_controller? ? "session" : "application"
  end
end
