class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.decimal :amount
      t.decimal :coinbase_fee
      t.decimal :bank_fee
      t.decimal :total_amount
      t.string :payment_method_id
      t.string :payment_method_name
      t.integer :action

      t.timestamps
    end
  end
end
