class SessionsController < ApplicationController
  require 'securerandom'
  require 'open-uri'
  require 'json'

  before_filter :ensure_signed_in, only: [:oauth]

  def new
    @auth_link = 'https://jiahaoli.scripts.mit.edu:444/bitstation/authenticate/?auth_token=' + generate_auth_token
    @nelly_auth_link = sessions_authenticate_path(auth_token: 'nelly') if Rails.env.development?
  end

  def authenticate
    result = nil
    token = params[:auth_token]

    if Rails.env.development? && token == 'nelly'
      result = {
        'success' => true,
        'message' => '',
        'kerberos' => 'nelsonliu',
        'name' => 'Nelson Liu'
      }
    else
      check_link = 'http://jiahaoli.scripts.mit.edu/bitstation/check/?auth_token=' + token
      result = JSON.parse(open(check_link).read)
    end

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
      redirect_to dashboard_url
    else
      redirect_to sessions_fail_url(message: 'Authentication failed. ')
    end
  end

  def fail
    flash[:error] = params[:message]
    redirect_to sign_in_url
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
      token = @oauth_client.auth_code.get_token(code, redirect_uri: coinbase_callback_uri)

      if current_user.coinbase_account.nil?
        flash[:coinbase_oauth_credentials] = token.to_hash
        redirect_to users_confirm_coinbase_account_url
      else
        client = coinbase_client_with_oauth_credentials(token.to_hash).
        email = client.get('/users').users[0].user.email

        if email != current_user.coinbase_account.email
          flash[:error] = 'Please authenticate with the Coinbase account that is linked to you only. '
          redirect_to root_url
          return
        end

        current_user.update_coinbase_oauth_credentials(token.to_hash)

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
