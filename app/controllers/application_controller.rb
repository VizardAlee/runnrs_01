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
      if session[:cart_id]
        cart = ShoppingCart.find_by(id: session[:cart_id], status: "active")
        if cart
          cart.update(user: current_user)
          session[:cart_id] = nil
        else
          cart = ShoppingCart.find_or_create_by(user: current_user, status: "active")
        end
      else
        cart = ShoppingCart.find_or_create_by(user: current_user, status: "active")
      end
    else
      cart = ShoppingCart.find_or_create_by(session_id: session.id.to_s, status: "active")
      session[:cart_id] ||= cart.id
    end

    cart
    # if user_signed_in?
    #   ShoppingCart.find_or_create_by(user: current_user, status: "active")
    # else
    #   ShoppingCart.find_or_create_by(session_id: session.id.to_s, status: "active") do |cart|
    #     cart.user_id = nil
    #   end
    # end
  end
end
