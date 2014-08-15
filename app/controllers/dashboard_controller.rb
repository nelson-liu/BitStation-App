class DashboardController < ApplicationController
  before_filter :ensure_signed_in, only: [:dashboard, :overview]
  before_filter :ensure_signed_in_without_redirect, only: [:account_summary, :transfer, :address_book, :contact_details, :add_contact, :transaction_history, :transaction_details, :buy_sell_bitcoin, :access_qrcode_details]
  before_filter :check_for_unlinked_coinbase_account, only: [:transfer, :address_book, :contact_details, :add_contact, :transaction_details, :buy_sell_bitcoin]
  # before_filter :disable_module, except: [:dashboard, :transfer]

  def dashboard
    @subtitle = "Dashboard"
  end

  def account_summary
    if has_coinbase_account_linked?
      @current_balance = current_coinbase_client.balance.to_d
      @current_balance_usd = current_coinbase_client.spot_price("USD").to_d * @current_balance
    end

    render layout: false
  end

  def transfer
    @send_money = params[:send_money]
    @default_currency = (params[:send_money][:currency] rescue 'USD')
    render layout: false
  end

  def address_book
    render layout: false
  end

  def contact_details
    render layout: false
  end

  def add_contact
    render layout: false
  end


  def transaction_details
    @transaction_id = params['id']
    client = current_coinbase_client

    @transaction = client.transaction(@transaction_id)['transaction']

    @transaction_date = Time.parse(@transaction['created_at']).localtime.to_s[0..-7]

    if @transaction['hsh'].nil?
      @footer = "This transaction occurred within the Coinbase network and off the blockchain with zero fees."
    else
      @footer = '<a target=“_blank” href="https://coinbase.com/network/transactions/' + @transaction['hsh'] + '">View this transaction on the blockchain</a>'
    end

    if @transaction[:sender].nil?
      @transaction_sender_name = "External BTC Address"
      @transaction_sender_email = "N/A"
    else
      @transaction_sender_name = @transaction[:sender][:name]
      @transaction_sender_email = @transaction[:sender][:email]
    end
    if @transaction[:recipient].nil?
      if @transaction[:sender][:email] == current_user.coinbase_account.email
        @transaction_recipient_name = "External BTC Address"
        @transaction_recipient_email = "N/A"
      else
        @transaction_recipient_name = current_user.name
        @transaction_recipient_email = "Sent to your receiving BTC Address"
      end
    else
      @transaction_recipient_name = @transaction[:recipient][:name]
      @transaction_recipient_email = @transaction[:recipient][:email]
    end

    # TODO: Get full names from our user database if possible, not coinbase
    @transaction_json = @transaction.to_json

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

  def bitstation_feed
    render layout: false
  end

  def overview
  end

  private

    def disable_module
      render inline: ''
    end
end
