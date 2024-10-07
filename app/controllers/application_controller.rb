class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :merge_cart_after_login, if: :user_signed_in?
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

  # Logic to manage the current shopping cart, depending on whether the user is signed in or not
  def current_cart
    if user_signed_in?
      handle_user_cart
    else
      handle_guest_cart
    end
  end

  private

  def handle_user_cart
    if session[:cart_id]
      cart = ShoppingCart.find_by(id: session[:cart_id], status: "active")
      
      if cart
        # Update user only if the cart doesn't already have a user
        cart.update(user: current_user) if cart.user.nil?
        session[:cart_id] = nil
      else
        cart = ShoppingCart.find_or_create_by(user: current_user, status: "active")
      end
    else
      cart = ShoppingCart.find_or_create_by(user: current_user, status: "active")
    end
  
    cart
  end
  

  def handle_guest_cart
    cart = ShoppingCart.find_or_create_by(session_id: session.id.to_s, status: "active")
    session[:cart_id] ||= cart.id
    cart
  end

  def merge_cart_after_login
    # Log the session cart and user cart information for debugging
    Rails.logger.debug "Session Cart ID: #{session[:cart_id]}"
    Rails.logger.debug "Current User ID: #{current_user.id}"
  
    session_cart = ShoppingCart.find_by(id: session[:cart_id], status: "active")
    user_cart = ShoppingCart.find_or_create_by(user: current_user, status: "active")
  
    Rails.logger.debug "Session Cart: #{session_cart.inspect}"
    Rails.logger.debug "User Cart: #{user_cart.inspect}"
  
    if session_cart && session_cart != user_cart
      merge_carts(user_cart, session_cart)
      session_cart.destroy
      session[:cart_id] = nil
    else
      Rails.logger.debug "No session cart found or session cart matches user cart."
    end
  end  

  def merge_carts(user_cart, session_cart)
    Rails.logger.debug "Merging session cart into user cart"
    
    session_cart.line_items.each do |item|
      Rails.logger.debug "Session Cart Item: #{item.inspect}"
  
      existing_item = user_cart.line_items.find_by(product_id: item.product_id, variation_id: item.variation_id)
      
      if existing_item
        Rails.logger.debug "Updating quantity for existing item: #{existing_item.inspect}"
        existing_item.update(quantity: existing_item.quantity + item.quantity)
      else
        Rails.logger.debug "Moving new item to user cart: #{item.inspect}"
        item.update(shopping_cart_id: user_cart.id)
      end
    end
  end
  
end
