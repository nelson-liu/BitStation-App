class AddStatusToPendingTransactions < ActiveRecord::Migration
  def change
    add_column :pending_transactions, :status, :integer
  end
end
