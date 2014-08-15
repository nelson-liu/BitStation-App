class MoneyRequestsController < ApplicationController
  before_filter :ensure_signed_in, only: [:show, :pay, :deny]
  before_filter :ensure_coinbase_account_linked, only: [:pay]

  def show
    @request = (MoneyRequest.find(params[:id].to_i) rescue nil)
    @should_show = (@request.sender == current_user || @request.requestee == current_user)
    @from = @request.sender == current_user ? 'You' : @request.sender.name
    @to = @request.requestee == current_user ? 'you' : @request.requestee.name

    render
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
      pt = PendingTransaction.create!({sender: current_user, recipient: request.sender, amount: request.amount, money_request: request})
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

    if error
      redirect_to dashboard_url, flash: {error: error}
    else
      request.denied!
      redirect_to dashboard_url, flash: {success: "You have successfully denied #{request.sender.name}'s money request. "}
    end
  end
end
