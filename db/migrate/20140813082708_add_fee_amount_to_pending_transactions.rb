class AddFeeAmountToPendingTransactions < ActiveRecord::Migration
  def change
    add_column :pending_transactions, :fee_amount, :decimal
  end
end
