class CreateCoinbaseAccounts < ActiveRecord::Migration
  def change
    create_table :coinbase_accounts do |t|
      t.string :email
      t.integer :user_id

      t.timestamps
    end
  end
end
