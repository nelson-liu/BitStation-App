class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.belongs_to :user, index: true
      t.belongs_to :associated_transaction, index: true
      t.text :content

      t.timestamps
    end
  end
end
