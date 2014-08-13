class TransactionsController < ApplicationController
  before_filter :ensure_signed_in, only: []
  before_filter :ensure_coinbase_account_linked, only: [:transact, :request_money, :history, :exchange]

  CURRENCIES = ["USD", "BTC"]

  MINIMUM_TRANSACTION_AMOUNT = {
    "BTC" => 0.001,
    "USD" => 0.5
  }

  def transact
    recipient = params[:kerberos]
    amount = params[:amount].to_f
    fee_amount = params[:fee_amount].to_f rescue 0
    currency = params[:currency]
    message = params[:message] || ''

    is_kerberos = (!recipient.nil?) && (recipient.length <= 10)
    is_btc = !is_kerberos

    user = User.find_by(kerberos: recipient) if is_kerberos

    unless CURRENCIES.include?(currency)
      flash[:error] = 'Invalid currency. '
      redirect_to dashboard_url
      return
    end

    if is_btc && (!Bitcoin::valid_address?(recipient))
      flash[:error] = 'Invalid BTC address. '
      redirect_to dashboard_url
      return
    end

    if is_kerberos && user.nil?
      flash[:error] = 'The designated recipient hasn\'t joined BitStation yet. '
      redirect_to dashboard_url
      return
    end

    if is_kerberos && user.coinbase_account.nil?
      flash[:error] = 'The designated recipient hasn\'t linked a Coinbase account yet. '
      redirect_to dashboard_url
      return
    end

    if is_kerberos && user == current_user
      flash[:error] = 'Why sending yourself money...? '
      redirect_to dashboard_url
      return
    end

    if amount.nil? || amount < MINIMUM_TRANSACTION_AMOUNT[currency]
      flash[:error] = "Invalid transfer amount. The minimum transaction amount is #{MINIMUM_TRANSACTION_AMOUNT} BTC."
      redirect_to dashboard_url
      return
    end

    amount /= (current_coinbase_client.spot_price(currency).to_d) unless currency == 'BTC'

    if amount > current_coinbase_client.balance.to_d
      flash[:error] = "You do not have enough funds in your Coinbase account. "
      redirect_to dashboard_url
      return
    end

    pt = is_kerberos ?
      PendingTransaction.create!({sender: current_user, recipient: user, amount: amount, message: message, fee_amount: fee_amount}) :
      PendingTransaction.create!({sender: current_user, recipient: nil, recipient_address: recipient, amount: amount, message: message, fee_amount: fee_amount})

    # FIXME ugh
    redirect_to @oauth_client.auth_code.authorize_url(redirect_uri: coinbase_callback_uri + '?pending_action=transact&pending_action_id=' + pt.id.to_s) + '&scope=send+user'
  end

  def request_money
    requestee = User.find_by(kerberos: params[:kerberos])
    amount = params[:amount].to_f rescue nil
    currency = params[:currency]
    message = params[:message]

    error = nil
    success = nil

    begin
      (error = 'Invalid currency. ' and raise) unless CURRENCIES.include?(currency)
      (error = 'The designated requestee hasn\'t joined BitStation yet. ' and raise) if requestee.nil?
      (error = 'The designated requestee hasn\'t linked a Coinbase account yet. ' and raise) if requestee.coinbase_account.nil?
      (error = 'Why requesting money from yourself...? ' and raise) if requestee == current_user
      (error = "Invalid transfer amount. The minimum transaction amount is #{MINIMUM_TRANSACTION_AMOUNT} BTC." and raise) if (amount.nil? || amount < MINIMUM_TRANSACTION_AMOUNT[currency])
    rescue
    end

    unless error
      amount /= (current_coinbase_client.spot_price(currency).to_d) unless currency == 'BTC'

      # FIXME more specific rescue here
      begin
        TransactionMailer.request_money(current_user, requestee, amount, message, dashboard_url(send_money: {
          recipient: current_user.kerberos,
          amount: amount,
          currency: 'BTC'
        })).deliver

        success = "You successfully sent the money request to #{requestee.name} at #{requestee.coinbase_account.email}. "
      rescue
        error = 'Failed to send the request. '
      end
    end

    @error = error
    @success = success

    respond_to do |format|
      format.js {}
      format.html { redirect_to dashboard_url, flash: {success: success, error: error}.delete_if { |k, v| v.nil? } }
    end
  end

  def history
  end

  def exchange
  end
end
