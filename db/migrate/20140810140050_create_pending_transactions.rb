class CreatePendingTransactions < ActiveRecord::Migration
  def change
    create_table :pending_transactions do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.decimal :amount
      t.text :message

      t.timestamps
    end
  end
end
