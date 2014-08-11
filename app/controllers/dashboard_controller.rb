class DashboardController < ApplicationController
  before_filter :ensure_signed_in, only: [:dashboard, :overview]
  before_filter :ensure_signed_in_without_redirect, only: [:account_summary, :transfer, :address_book, :transaction_history, :exchange_currencies, :manage_account]

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
    render layout: false
  end

  def address_book
    render layout: false
  end

  def address_book_detailed
    render layout: false
  end

  def transaction_history
    if has_coinbase_account_linked?
      client = current_coinbase_client
      page = params[:page] || 1
      page = page.to_i
      @current_page = page

      @transactions = client.transactions(page, limit: TRANSACTION_HISTORY_ENTRIES_PER_PAGE)
      # FIXME assuming the user has no more than 1000 transfers
      @transfers = client.transfers(limit: [1000, page * TRANSACTION_HISTORY_ENTRIES_PER_PAGE].min)
      @transfers = @transfers['transfers'].map { |t| t['transfer'] }
      @history = @transactions['transactions'].map { |t| t['transaction'] }

      @history.each do |e|
        ts = @transfers.select { |t| t['transaction_id'] == e['id'] }
        e['transfer_type'] = ts.first['type'].downcase unless ts.empty?
      end

      @coinbase_id = @transactions['current_user']['id']
      @might_have_next_page = (@history.size == TRANSACTION_HISTORY_ENTRIES_PER_PAGE)
    end

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

  def transaction_history_detailed
    render layout: false
  end

  def exchange_currencies
    render layout: false
  end

  def manage_account
    render layout: false
  end

  def overview
  end
end
