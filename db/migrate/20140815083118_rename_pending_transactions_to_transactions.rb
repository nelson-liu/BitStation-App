class RenamePendingTransactionsToTransactions < ActiveRecord::Migration
  def change
    rename_table :pending_transactions, :transactions
  end
end
