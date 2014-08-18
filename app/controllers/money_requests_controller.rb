class MoneyRequestsController < ApplicationController
  before_filter :ensure_signed_in, only: [:show, :pay, :deny]
  before_filter :ensure_signed_in_without_redirect, only: [:index]
  before_filter :ensure_coinbase_account_linked, only: [:pay]

  include ApplicationHelper

  MONEY_REQUEST_HISTORY_ENTRIES_PER_PAGE = 11

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

  def index
    page = [params[:page].to_i, 1].max

    rs = current_user.outgoing_money_requests.to_a + current_user.incoming_money_requests.to_a

    @display = rs.map { |r| r.to_display_data(current_user) }.sort_by { |r| r[:time] }.reverse.drop((page - 1) * MONEY_REQUEST_HISTORY_ENTRIES_PER_PAGE).first(MONEY_REQUEST_HISTORY_ENTRIES_PER_PAGE)

    respond_to do |format|
      format.js do
        @rendered_html = render_to_string(formats: [:html]).lines.map { |l| l.strip }.join('').html_safe
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
