class AddIsPublicToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :is_public, :boolean
  end
end
