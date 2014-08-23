class TransfersController < ApplicationController
  class TransferParameterError < StandardError; end

  def create
    transfer_action = params[:transfer_action]
    amount = params[:amount].to_f
    ptr = nil
    @error = nil

    begin
      (@error = "You do not have enough funds in your Coinbase account. " and raise TransactionParameterError) if amount > current_coinbase_client.balance.to_d && transfer_action == "sell"
      if transfer_action == "buy"
        prices = current_coinbase_client.get('/prices/buy', {"qty"=>amount}).to_hash
        ptr =Transfer.create!({
          user_id: current_user.id, 
          action: "buy",
          amount: amount, 
          status: :pending,
          subtotal: prices["subtotal"]["amount"],
          coinbase_fee: prices["fees"].select { |p| p.keys.include?("coinbase") }.first["coinbase"]["amount"],
          bank_fee: prices["fees"].select { |p| p.keys.include?("bank") }.first["bank"]["amount"],
          total_amount: prices["total"]["amount"],
          })
      elsif transfer_action == "sell"
        prices = current_coinbase_client.get('/prices/sell', {"qty"=>amount}).to_hash
        ptr = Transfer.create!({
          user_id: current_user.id, 
          action: "sell",
          amount: amount, 
          status: :pending,
          subtotal: prices["subtotal"]["amount"],
          coinbase_fee: prices["fees"].select { |p| p.keys.include?("coinbase") }.first["coinbase"]["amount"],
          bank_fee: prices["fees"].select { |p| p.keys.include?("bank") }.first["bank"]["amount"],
          total_amount: prices["total"]["amount"],
          })
      end
    rescue TransferParameterError
    end
    respond_to do |format|
      format.html do
        if @error
          redirect_to dashboard_url, flash: {error: @error}
        else
          # FIXME ugh
          redirect_to @oauth_client.auth_code.authorize_url(redirect_uri: coinbase_callback_uri + '?pending_action=transfer&pending_action_id=' + ptr.id.to_s) + '&scope=buy+sell+user'
        end
      end
    end
  end

  def index
  end

  def get_price
    amount = params[:amount]
    action = params[:type]
    if action == "buy"
      prices = current_coinbase_client.get('/prices/buy', {"qty"=>amount}).to_hash
    else
      prices = current_coinbase_client.get('/prices/sell', {"qty"=>amount}).to_hash
    end
    result = [
      prices["subtotal"]["amount"], 
      prices["fees"].select { |p| p.keys.include?("coinbase") }.first["coinbase"]["amount"], 
      prices["fees"].select { |p| p.keys.include?("bank") }.first["bank"]["amount"], 
      prices["total"]["amount"]
    ]
    logger.info result
    render json: result
  end
end
