class AddCoinbaseTransactionIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :coinbase_transaction_id, :string
  end
end
