class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :prepare_flash_class_variable
  before_filter :prepare_oauth_client
  before_filter :warn_unlinked_coinbase_account
  after_filter :check_for_refreshed_token
  #around_filter :rescue_unhandled_exception

  COINBASE_CLIENT_ID = 'c0ce8b898aa60d616b3a4051d65d19b3d2dff5ed05f78c5c761cfb2f8806b7bb'
  COINBASE_CLIENT_SECRET = '72bbe98c81e7b02765812e0c3c059d453cdf28bb45e6e6067dea9363ba618b74'
  COINBASE_CALLBACK_URI = 'http://localhost:3000/sessions/oauth'

  private

    def check_for_refreshed_token
      # Check only if the user has account linked and api calls have been made
      return unless has_coinbase_account_linked?
      return if @current_coinbase_client.nil?

      new_credentials = @current_coinbase_client.credentials
      current_user.update_coinbase_oauth_credentials(new_credentials) unless (new_credentials == current_user.coinbase_account.oauth_credentials)
    end

    def ensure_signed_in
      unless signed_in?
        flash[:error] = "Please sign in first. "
        redirect_to sign_in_url
      end
    end

    def ensure_coinbase_account_linked
      ensure_signed_in
      if current_user.coinbase_account.nil?
        flash[:error] = "You need to link a Coinbase account first. "
        redirect_to users_link_coinbase_account_url
      end
    end

    def prepare_flash_class_variable
      @flash ||= {}
    end

    def prepare_oauth_client
      @oauth_client = OAuth2::Client.new(COINBASE_CLIENT_ID, COINBASE_CLIENT_SECRET, site: 'https://coinbase.com')
    end

    def warn_unlinked_coinbase_account
      if signed_in? && current_user.coinbase_account.nil?
        @flash[:warning] = "You haven't linked a Coinbase account yet. You can link it #{view_context.link_to 'here', users_link_coinbase_account_path}. ".html_safe
      end
    end

    def signed_in?
      current_user != nil
    end

    def sign_in(user)
      session[:user_id] = user.id
      session[:auth_token] = user.auth_token
    end

    def has_coinbase_account_linked?
      signed_in? && !current_user.coinbase_account.nil?
    end

    def current_user
      if @current_user
        @current_user
      else
        @current_user = session[:user_id] && session[:auth_token] && User.find_by(id: session[:user_id], auth_token: session[:auth_token])
      end
    end

    def coinbase_client_with_oauth_credentials(credentials)
      Coinbase::OAuthClient.new(COINBASE_CLIENT_ID, COINBASE_CLIENT_SECRET, credentials.symbolize_keys)
    end

    def current_coinbase_client
      if current_user.coinbase_account && current_user.coinbase_account.oauth_credentials
        @current_coinbase_client ||= coinbase_client_with_oauth_credentials(current_user.coinbase_account.oauth_credentials)
      else
        nil
      end
    end

    def clear_current_coinbase_oauth_token
      @current_coinbase_client = nil
    end

    def current_user_name
      current_user ? current_user.name : 'Guest'
    end

    def sign_out
      session[:user_id] = nil
      session[:auth_token] = nil
    end

    def rescue_unhandled_exception
      begin
        yield
      rescue
        flash[:error] = 'An unknown error happened. '
        redirect_to root_url
      end
    end

    helper_method :current_user, :signed_in?, :current_user_name, :has_coinbase_account_linked?
end
