class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_cart

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :password_confirmation])
  end

  private

  def current_cart
    if user_signed_in?
      ShoppingCart.find_or_create_by(user: current_user, status: "active")
    else
      ShoppingCart.find_or_create_by(session_id: session.id.to_s, status: "active") do |cart|
        cart.user_id = nil
      end
    end
  end
end
