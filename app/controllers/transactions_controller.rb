class TransactionsController < ApplicationController
  before_filter :ensure_signed_in, only: []
  before_filter :ensure_coinbase_account_linked, only: [:create, :index, :show]
  before_filter :check_for_unlinked_coinbase_account, only: [:index]

  include ApplicationHelper

  CURRENCIES = ["USD", "BTC"]

  MINIMUM_TRANSACTION_AMOUNT = {
    "BTC" => 0.001,
    "USD" => 0.5
  }

  TRANSACTION_HISTORY_ENTRIES_PER_PAGE = 11
  DETAILED_TRANSACTION_HISTORY_ENTRIES_PER_PAGE = 100

  class TransactionParameterError < StandardError; end

  def create
    recipient = params[:kerberos]
    amount = params[:amount].to_f
    fee_amount = params[:fee_amount].to_f rescue 0
    currency = params[:currency]
    message = params[:message] || ''
    pt = nil

    @error = nil

    is_kerberos = (!recipient.nil?) && (recipient.length <= 10)
    is_btc = !is_kerberos

    user = User.find_by(kerberos: recipient) if is_kerberos

    begin
      (@error = 'Invalid currency. ' and raise TransactionParameterError) unless CURRENCIES.include?(currency)
      (@error = 'Invalid BTC address. ' and raise TransactionParameterError) if is_btc && (!Bitcoin::valid_address?(recipient))
      (@error = 'The designated recipient hasn\'t joined BitStation yet. ' and raise TransactionParameterError) if is_kerberos && user.nil?
      (@error = 'The designated recipient hasn\'t linked a Coinbase account yet. ' and raise TransactionParameterError) if is_kerberos && user.coinbase_account.nil?
      (@error = 'Why sending yourself money...? ' and raise TransactionParameterError) if is_kerberos && user == current_user
      (@error = "Invalid transfer amount. The minimum transaction amount is #{MINIMUM_TRANSACTION_AMOUNT[currency]} #{currency}." and raise TransactionParameterError) if amount.nil? || amount < MINIMUM_TRANSACTION_AMOUNT[currency]

      amount /= (current_coinbase_client.spot_price(currency).to_d) unless currency == 'BTC'
      (@error = "You do not have enough funds in your Coinbase account. " and raise TransactionParameterError) if amount > current_coinbase_client.balance.to_d

      pt = is_kerberos ?
        Transaction.create!({sender: current_user, recipient: user, amount: amount, message: message, fee_amount: fee_amount}) :
        Transaction.create!({sender: current_user, recipient: nil, recipient_address: recipient, amount: amount, message: message, fee_amount: fee_amount})
    rescue TransactionParameterError
    end

    respond_to do |format|
      format.html do
        if @error
          redirect_to dashboard_url, flash: {error: @error}
        else
          # FIXME ugh
          redirect_to @oauth_client.auth_code.authorize_url(redirect_uri: coinbase_callback_uri + '?pending_action=transact&pending_action_id=' + pt.id.to_s) + '&scope=send+user'
        end
      end
    end
  end

  def index
    client = current_coinbase_client
    page = params[:page] || 1
    page = page.to_i
    current_page = page
    entries_per_page = params[:detailed] ? DETAILED_TRANSACTION_HISTORY_ENTRIES_PER_PAGE : TRANSACTION_HISTORY_ENTRIES_PER_PAGE

    cb_response = client.transactions(page, limit: entries_per_page)
    coinbase_id = cb_response['current_user']['id']
    num_pages = cb_response['num_pages'].to_i
    # FIXME assuming the user has no more than 1000 transfers
    transfers = client.transfers(limit: [1000, page * entries_per_page].min)
    transfers = transfers['transfers'].map { |t| t['transfer'] }
    cb_transactions = cb_response['transactions'].map { |t| t['transaction'] }

    cb_transactions.each do |e|
      ts = transfers.select { |t| t['transaction_id'] == e['id'] }
      e['transfer_type'] = ts.first['type'].downcase unless ts.empty?
    end

    @display = cb_transactions.map do |t|
      # TODO ignore request transactions for now
      next if t['request']
      Transaction.display_data_from_cb_transaction(t, coinbase_id)
    end

    @next_page = (current_page < num_pages) ? transactions_path(page: current_page + 1) : nil
    @prev_page = (current_page != 1) ? transactions_path(page: current_page - 1) : nil

    if params[:detailed]
      render "index_detailed", layout:false
    else
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
  end


  def show
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
      @transaction_sender_email = @transaction[:sender_address]
    else
      @transaction_sender_name = @transaction[:sender][:name]
      @transaction_sender_email = @transaction[:sender][:email]
    end
    if @transaction[:recipient].nil?
      if @transaction[:sender][:email] == current_user.coinbase_account.email
        @transaction_recipient_name = "External BTC Address"
        @transaction_recipient_email = @transaction[:recipient_address]
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
end
