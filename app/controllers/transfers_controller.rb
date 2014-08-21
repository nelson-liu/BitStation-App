class TransfersController < ApplicationController
  def create
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
