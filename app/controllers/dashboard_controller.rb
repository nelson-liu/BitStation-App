class DashboardController < ApplicationController
  before_filter :ensure_signed_in, only: [:dashboard, :overview]
  before_filter :ensure_signed_in_without_redirect, only: [:account_summary, :transfer, :address_book, :transaction_history, :exchange_currencies, :manage_account]

  def dashboard
  end

  def account_summary
    if has_coinbase_account_linked?
      @current_balance = current_coinbase_client.balance.format
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
    render layout: false
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
