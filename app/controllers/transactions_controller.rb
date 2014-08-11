class TransactionsController < ApplicationController
  before_filter :ensure_signed_in, only: []
  before_filter :ensure_coinbase_account_linked, only: [:transact, :history, :exchange]

  CURRENCIES = ["USD", "BTC"]

  MINIMUM_TRANSACTION_AMOUNT = {
    "BTC" => 0.001,
    "USD" => 0.5
  }

  def transact
    recipient = params[:kerberos]
    amount = params[:amount].to_f
    currency = params[:currency]
    message = params[:message] || ''

    user = User.find_by(kerberos: recipient)

    unless CURRENCIES.include?(currency)
      flash[:error] = 'Invalid currency. '
      redirect_to dashboard_url
      return
    end

    if user.nil?
      flash[:error] = 'The designated recipient hasn\'t joined BitStation yet. '
      redirect_to dashboard_url
      return
    end

    if user.coinbase_account.nil?
      flash[:error] = 'The designated recipient hasn\'t linked a Coinbase account yet. '
      redirect_to dashboard_url
      return
    end

    if user == current_user
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

    pt = PendingTransaction.create!({sender: current_user, recipient: user, amount: amount, message: message})
    redirect_to @oauth_client.auth_code.authorize_url(redirect_uri: coinbase_callback_uri + '?pending_action=transact&pending_action_id=' + pt.id.to_s, scope: 'send')
  end

  def history
  end

  def exchange
  end
end
