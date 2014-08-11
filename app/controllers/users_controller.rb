class UsersController < ApplicationController
  before_filter :ensure_signed_in, only: [:link_coinbase_account, :confirm_coinbase_account, :unlink_coinbase_account, :access_qrcode]

  QRCODE_DEFAULT_SIZE = 300

  def link_coinbase_account
    # FIXME writing out the scope query is ugly but authorize_url over-escapes it
    redirect_to @oauth_client.auth_code.authorize_url(redirect_uri: coinbase_callback_uri) + "&scope=balance+addresses+user+transactions+transfers"
  end

  def confirm_coinbase_account
    unless current_user.coinbase_account.nil?
      flash[:error] = 'You already have a Coinbase account linked. '
      redirect_to root_url
      return
    end

    begin
      client = coinbase_client_with_oauth_credentials(flash[:coinbase_oauth_credentials])
      email = client.get('/users').users[0].user.email

      if CoinbaseAccount.find_by({email: email})
        flash[:error] = 'The Coinbase account is already linked to another user. '
        redirect_to dashboard_url
        return
      end

      CoinbaseAccount.create!({user: current_user, email: email})
      current_user.update_coinbase_oauth_credentials(flash[:coinbase_oauth_credentials])

      flash[:success] = "You have successfully linked your Coinbase account #{email}. "
      redirect_to root_url
    rescue
      flash[:error] = 'Invalid Coinbase authentication. '
      redirect_to root_url
    end
  end

  def unlink_coinbase_account
    # Do nothing if the user doesn't already have a Coinbase account linked
    if current_user.coinbase_account.nil?
      redirect_to root_url
      return
    end

    clear_current_coinbase_oauth_token
    current_user.update_coinbase_oauth_credentials(nil)
    current_user.coinbase_account.destroy!
    current_user.update!({coinbase_account: nil})

    flash[:success] = "You have successfully unlinked your Coinbase account. "
    redirect_to root_url
  end

  def access_qrcode
    require 'cgi'
    size = params[:size] || QRCODE_DEFAULT_SIZE
    text = sessions_authenticate_url(access_code: current_user.new_access_code)
    url = "http://api.qrserver.com/v1/create-qr-code/?size=#{size}x#{size}&data=#{CGI.escape(text)}"
    redirect_to url
  end
end
