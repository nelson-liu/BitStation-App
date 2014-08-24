class RecreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.belongs_to :user, index: true
      t.text :coinbase_transaction_id
      t.text :content

      t.timestamps
    end
  end
end
