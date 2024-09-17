class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    # Check if the user is a regular user and if there is a return_to path in the session
    if resource.role == 'regular' && session[:return_to]
      session.delete(:return_to) # Clean up the session
    else
      root_path # Fallback to root or any other path if there's no return_to
    end
  end
end
