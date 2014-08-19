class DashboardController < ApplicationController
  before_filter :ensure_signed_in, only: [:dashboard, :overview]
  before_filter :ensure_signed_in_without_redirect, only: [:account_summary, :transfer, :transaction_history, :transaction_details, :buy_sell_bitcoin, :access_qrcode_details]
  before_filter :check_for_unlinked_coinbase_account, only: [:transfer, :address_book, :transaction_details, :buy_sell_bitcoin]

  def dashboard
    store_location
    @subtitle = "Dashboard"
    @popup = params[:popup]
  end

  def transfer
    @default_currency = 'USD'
    @exchange_rate = current_coinbase_client.spot_price("USD").to_d

    render layout: false
  end

  def account_summary
    if has_coinbase_account_linked?
      @current_balance = current_coinbase_client.balance.to_d
      @current_balance_usd = current_coinbase_client.spot_price("USD").to_d * @current_balance
    end

    render layout: false
  end

  def access_qrcode_details
    @qr_path = access_qrcode_path(current_user, r: Time.now.to_f.to_s)
    render layout: false
  end

  def buy_sell_bitcoin
    @current_sell_price = current_coinbase_client.sell_price(1).to_d
    @current_buy_price = current_coinbase_client.buy_price(1).to_d
    render layout: false
  end

  def get_price
    render json: [1, 2, 3, 4].to_json
  end

  def bitstation_feed
    render layout: false
  end
end
