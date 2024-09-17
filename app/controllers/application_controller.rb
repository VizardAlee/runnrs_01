class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_cart

  protected

  # Permitting additional parameters for Devise sign-up
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :password_confirmation])
  end

  # Override Devise's after sign-up redirect path
  def after_sign_up_path_for(resource)
    # Check if the user is a regular customer and redirect to the stored location (product page) or root
    if resource.role == "regular"
      stored_location_for(:user) || product_path(params[:product_id])
    else
      super
    end
  end

  # Override Devise's after sign-in redirect path
  def after_sign_in_path_for(resource)
    # Check if the user is a regular customer and redirect to the stored location (product page) or root
    if resource.role == "regular"
      stored_location_for(:user) || root_path
    else
      super
    end
  end

  private

  # Logic to manage the current shopping cart, depending on whether the user is signed in or not
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
  end
end
