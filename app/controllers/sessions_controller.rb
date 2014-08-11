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
      callback_uri = coinbase_callback_uri
      pending_action = params[:pending_action]
      pending_action_id = params[:pending_action_id]
      callback_uri += ('?pending_action=' + pending_action) unless pending_action.nil?
      callback_uri += ('&pending_action_id=' + pending_action_id.to_s) unless pending_action_id.nil?
      pending_action_id = pending_action_id.to_i unless pending_action_id.nil?

      code = params[:code]
      token = @oauth_client.auth_code.get_token(code, redirect_uri: callback_uri)

      if pending_action.nil?
        # Normal non-critical OAuth authentication
        if current_user.coinbase_account.nil?
          flash[:coinbase_oauth_credentials] = token.to_hash
          redirect_to users_confirm_coinbase_account_url
        else
          client = coinbase_client_with_oauth_credentials(token.to_hash)
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
      elsif pending_action == 'transact'
        # It's a pending transaction
        pt = PendingTransaction.find(pending_action_id)

        if pt.sender != current_user
          flash[:error] = "Please authenticate with the Coinbase accuont that is linked to you only. "
          redirect_to dashboard_url
          return
        end

        begin
          if process_pending_transaction(pt, token)
            flash[:success] = "You have successfully given #{pt.recipient.name} #{pt.amount} BTC. "
            redirect_to dashboard_url
          else
            raise
          end
        rescue
          flash[:error] = "Transaction failed. Maybe you do not have enough funds? "
          redirect_to dashboard_url
        end
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

    def process_pending_transaction(pt, oauth_token)
      critical_client = coinbase_client_with_oauth_credentials(oauth_token.to_hash)
      r = critical_client.send_money(pt.recipient.coinbase_account.email, pt.amount, pt.message)
      pt.destroy!
      r.success?
    end
end
