class AddMessageToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :message, :text
  end
end
