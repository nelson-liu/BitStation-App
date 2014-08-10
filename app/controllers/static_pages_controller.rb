class StaticPagesController < ApplicationController
  def homepage
    @balance = current_coinbase_client.balance if has_coinbase_account_linked?
  end
end
