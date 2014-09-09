class MoneyRequestsController < ApplicationController
  before_filter :ensure_signed_in, only: [:show, :pay, :deny]
  before_filter :ensure_signed_in_without_redirect, only: [:index, :create]
  before_filter :ensure_coinbase_account_linked, only: [:pay, :create]

  include ApplicationHelper

  MONEY_REQUEST_HISTORY_ENTRIES_PER_PAGE = 11

  CURRENCIES = ["USD", "BTC"]

  MINIMUM_TRANSACTION_AMOUNT = {
    "BTC" => 0.001,
    "USD" => 0.5
  }

  def create
    requestee = User.find_by(kerberos: params[:kerberos])
    amount = params[:amount_btc].to_f rescue nil
    currency = 'BTC'
    message = params[:message]

    error = nil
    success = nil

    begin
      (error = 'Invalid currency. ' and raise) unless CURRENCIES.include?(currency)
      (error = 'The designated requestee hasn\'t joined BitStation yet. ' and raise) if requestee.nil?
      (error = 'The designated requestee hasn\'t linked a Coinbase account yet. ' and raise) if requestee.coinbase_account.nil?
      (error = 'Why requesting money from yourself...? ' and raise) if requestee == current_user
      (error = "Invalid request amount. The minimum transaction amount is #{MINIMUM_TRANSACTION_AMOUNT[currency]} #{currency}." and raise) if (amount.nil? || amount < MINIMUM_TRANSACTION_AMOUNT[currency])
    rescue
    end

    unless error
      exchange_rate = current_coinbase_client.spot_price(currency).to_d
      amount /= exchange_rate unless currency == 'BTC'
      dollar_amount = amount * exchange_rate

      # FIXME more specific rescue here
      begin
        mr = MoneyRequest.create!({
          sender: current_user,
          requestee: requestee,
          amount: amount,
          dollar_amount: dollar_amount,
          message: message
        })

        mr.pending!

        TransactionMailer.request_money(current_user, requestee, amount, dollar_amount, message, dashboard_url({
          popup: money_request_path(mr)
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

  def show
    @request = (MoneyRequest.find(params[:id].to_i) rescue nil)
    @should_show = (@request.sender == current_user || @request.requestee == current_user)
    @from = @request.sender == current_user ? 'You' : @request.sender.name
    @to = @request.requestee == current_user ? 'you' : @request.requestee.name

    render layout: false
  end

  def pay
    request = (MoneyRequest.find(params[:id].to_i) rescue nil)

    error = nil

    begin
      (error = 'Invalid request to pay. ' and raise) if request.nil?
      (error = 'Request already cancelled. ' and raise) if request.cancelled?
      (error = 'Request already paid or denied. ' and raise) unless request.pending?
      (error = 'Insufficient balance. ' and raise) if request.amount > current_coinbase_client.balance.to_d
    rescue
    end

    if error
      redirect_to dashboard_url, flash: {error: error}
    else
      pt = Transaction.create!({sender: current_user, recipient: request.sender, amount: request.amount, money_request: request})
      redirect_to @oauth_client.auth_code.authorize_url(redirect_uri: coinbase_callback_uri + '?pending_action=transact&pending_action_id=' + pt.id.to_s) + '&scope=send+user'
    end
  end

  def deny
    request = (MoneyRequest.find(params[:id].to_i) rescue nil)

    error = nil

    begin
      (error = 'Invalid request to pay. ' and raise) if request.nil?
      (error = 'Request already cancelled. ' and raise) if request.cancelled?
      (error = 'Request already paid or denied. ' and raise) unless request.pending?
    rescue
    end

    success = "You have successfully denied #{request.sender.name}'s money request. " unless error
    request.denied! unless error

    @error = error
    @success = success

    respond_to do |format|
      format.js {}

      format.html do
        if error
          redirect_to dashboard_url, flash: {error: error}
        else
          redirect_to dashboard_url, flash: {success: success}
        end
      end
    end
  end

  def cancel
    request = (MoneyRequest.find(params[:id].to_i) rescue nil)

    error = nil

    begin
      (error = 'Invalid request to cancel. ' and raise) if request.nil?
      (error = 'Request already cancelled. ' and raise) if request.cancelled?
    rescue
    end

    success = "You have successfully cancelled #{request.sender.name}'s money request. " unless error
    request.cancelled! unless error

    @error = error
    @success = success

    respond_to do |format|
      format.js {}

      format.html do
        if error
          redirect_to dashboard_url, flash: {error: error}
        else
          redirect_to dashboard_url, flash: {success: success}
        end
      end
    end
  end

  def index
    page = [params[:page].to_i, 1].max

    rs = current_user.outgoing_money_requests.to_a + current_user.incoming_money_requests.to_a

    @display = rs.map { |r| r.to_display_data(current_user) }.sort_by { |r| r[:time] }.reverse.drop((page - 1) * MONEY_REQUEST_HISTORY_ENTRIES_PER_PAGE).first(MONEY_REQUEST_HISTORY_ENTRIES_PER_PAGE)

    respond_to do |format|
      format.js do
        @rendered_html = render_to_string(formats: [:html]).lines.join('').html_safe
        # raise @rendered_html.lines.count.to_s
        render formats: [:js]
      end

      format.html do
        render layout: false
      end
    end
  end

  def resend
    request = (MoneyRequest.find(params[:id].to_i) rescue nil)

    begin
      (@error = 'No such request. ' and raise) if request.nil?
      (@error = 'Request already responded to. ' and raise) unless request.pending?

      begin
        TransactionMailer.request_money(
          request.sender,
          request.requestee,
          request.amount,
          request.dollar_amount,
          request.message,
          dashboard_url({
            popup: money_request_path(request)
          }),
          true
        ).deliver

        @success = "You have successfully resent the request to #{request.requestee.name}. "
      rescue
        @error = 'Resending request email failed. '
      end
    rescue
    end

    respond_to do |format|
      format.js {}

      format.html do
        if @error
          redirect_to dashboard_url, flash: {error: @error}
        else
          redirect_to dashboard_url, flash: {success: @success}
        end
      end
    end
  end
end
