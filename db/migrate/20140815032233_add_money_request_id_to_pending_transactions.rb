class AddMoneyRequestIdToPendingTransactions < ActiveRecord::Migration
  def change
    add_column :pending_transactions, :money_request_id, :integer
  end
end
