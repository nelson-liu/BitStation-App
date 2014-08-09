class SessionsController < ApplicationController
  require 'securerandom'
  require 'open-uri'
  require 'json'

  before_filter :ensure_signed_in, only: [:oauth]

  def new
    @auth_link = 'https://jiahaoli.scripts.mit.edu:444/bitstation/authenticate/?auth_token=' + generate_auth_token
  end

  def authenticate
    token = params[:auth_token]
    check_link = 'http://jiahaoli.scripts.mit.edu/bitstation/check/?auth_token=' + token
    result = JSON.parse(open(check_link).read)

    if result && result["success"]
      user = User.find_by(kerberos: result["kerberos"])

      if user.nil?
        user = User.create({
          kerberos: result["kerberos"],
          name: result["name"]
        })
      end

      user.auth_token = token
      user.save

      sign_in user

      flash[:success] = "You have successfully signed in as #{user.name}. "
      redirect_to root_path
    else
      redirect_to sessions_fail_path(message: 'Authentication failed. ')
    end
  end

  def fail
    flash[:error] = params[:message]
    redirect_to root_path
    # @message = params[:message]
  end

  def destroy
    if signed_in?
      sign_out
      flash[:success] = "You have successfully signed out. "
    end
    redirect_to root_path
  end

  def oauth
    begin
      code = params[:code]
      token = @oauth_client.auth_code.get_token(code, redirect_uri: COINBASE_CALLBACK_URI)
      session[:coinbase_oauth_token] = token.to_hash

      if current_user.coinbase_account.nil?
        redirect_to users_confirm_coinbase_account_url
      else
        flash[:success] = 'You have successfully authenticated your Coinbase account. '
        redirect_to root_url
      end
    rescue OAuth2::Error
      flash[:error] = 'Authentication for Coinbase failed. '
      redirect_to root_url
    end
  end

  private

    def generate_auth_token
      SecureRandom.hex
    end
end
