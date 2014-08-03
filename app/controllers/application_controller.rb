class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

    def signed_in
      current_user != nil
    end

    def sign_in(user)
      session[:user_id] = user.id
    end

    def current_user
      if @current_user
        @current_user
      else
        @current_user = session[:user_id] && User.find(session[:user_id])
      end
    end

    def current_user_name
      current_user ? current_user.name : 'Guest'
    end

    def sign_out
      session[:user_id] = nil
    end

    helper_method :current_user, :signed_in, :current_user_name
end
