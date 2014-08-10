class DashboardController < ApplicationController
  before_filter :ensure_signed_in, only: [:dashboard, :overview]

  def dashboard
    if has_coinbase_account_linked?
      @current_balance = current_coinbase_client.balance.format
    end
  end

  def overview
  end
end
