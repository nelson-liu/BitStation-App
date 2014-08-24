class RemoveNotes < ActiveRecord::Migration
  def change
    drop_table :notes
  end
end
