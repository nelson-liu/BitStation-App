class DashboardController < ApplicationController
  before_filter :ensure_signed_in, only: [:dashboard, :overview]
  before_filter :ensure_signed_in_without_redirect, only: [:account_summary, :transfer, :address_book, :transaction_history, :transaction_details, :buy_sell_bitcoin, :access_qrcode_details]
  before_filter :check_for_unlinked_coinbase_account, only: [:transfer, :transaction_history, :transaction_details, :buy_sell_bitcoin]

  TRANSACTION_HISTORY_ENTRIES_PER_PAGE = 12

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

  def address_book_detailed
    render layout: false
  end

  def transaction_history
    client = current_coinbase_client
    page = params[:page] || 1
    page = page.to_i
    @current_page = page

    @transactions = client.transactions(page, limit: TRANSACTION_HISTORY_ENTRIES_PER_PAGE)
    @num_pages = @transactions['num_pages'].to_i
    # FIXME assuming the user has no more than 1000 transfers
    @transfers = client.transfers(limit: [1000, page * TRANSACTION_HISTORY_ENTRIES_PER_PAGE].min)
    @transfers = @transfers['transfers'].map { |t| t['transfer'] }
    @history = @transactions['transactions'].map { |t| t['transaction'] }

    @history.each do |e|
      ts = @transfers.select { |t| t['transaction_id'] == e['id'] }
      e['transfer_type'] = ts.first['type'].downcase unless ts.empty?
    end

    @coinbase_id = @transactions['current_user']['id']
    @might_have_next_page = (@current_page < @num_pages)

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
      @transaction_sender_name = "External Account"
      @transaction_sender_email = "N/A"
    else
      @transaction_sender_name = @transaction[:sender][:name]
      @transaction_sender_email = @transaction[:sender][:email]
    end
    if @transaction[:recipient].nil?
      @transaction_recipient_name = "External Account"
      @transaction_recipient_email = "N/A"
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

  def transaction_history_detailed
    render layout: false
  end

  def buy_sell_bitcoin
    @current_sell_price = current_coinbase_client.sell_price(1).to_d
    render layout: false
  end

  def bitstation_feed
    render layout: false
  end

  def overview
  end

  private

    def check_for_unlinked_coinbase_account
      render 'unlinked_coinbase_account', layout: false unless has_coinbase_account_linked?
    end
end
