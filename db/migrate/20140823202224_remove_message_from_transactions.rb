class RemoveMessageFromTransactions < ActiveRecord::Migration
  def change
    remove_column :transactions, :message
  end
end
