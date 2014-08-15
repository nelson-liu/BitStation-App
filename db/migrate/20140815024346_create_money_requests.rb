class CreateMoneyRequests < ActiveRecord::Migration
  def change
    create_table :money_requests do |t|
      t.integer :sender_id
      t.integer :requestee_id
      t.integer :status
      t.decimal :amount
      t.text :message

      t.timestamps
    end
  end
end
