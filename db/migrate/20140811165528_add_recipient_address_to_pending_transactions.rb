class AddRecipientAddressToPendingTransactions < ActiveRecord::Migration
  def change
    add_column :pending_transactions, :recipient_address, :string
  end
end
