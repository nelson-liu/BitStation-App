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
    @is_module = true
    @default_currency = 'USD'
    @exchange_rate = current_coinbase_client.spot_price("USD").to_d

    render layout: false
  end

  def account_summary
    @is_module = true
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

  def view_public_addresses
    @public_address = current_coinbase_client.get('/addresses').to_hash
    @public_address = @public_address["addresses"]
    render layout: false
  end

  def buy_sell_bitcoin
    @is_module = true
    @current_sell_price = current_coinbase_client.get('/prices/sell', {"qty"=>"1"})["subtotal"]["amount"]
    @current_buy_price = current_coinbase_client.get('/prices/buy', {"qty"=>"1"})["subtotal"]["amount"]
    render layout: false
  end

  def bitstation_feed
    @is_module = true
    render layout: false
  end

  private

    def check_for_unlinked_coinbase_account
      render 'unlinked_coinbase_account', layout: false unless has_coinbase_account_linked?
    end

    def disable_module
      render inline: ''
    end
end
