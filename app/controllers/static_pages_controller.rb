class StaticPagesController < ApplicationController
  def homepage
    @balance = current_coinbase_client.balance if has_coinbase_account_linked?
  end
  def about
  end
  def faq
  end
  def privacy
  end
  def security
  end
  def team
  end
end
