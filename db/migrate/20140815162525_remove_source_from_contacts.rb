class RemoveSourceFromContacts < ActiveRecord::Migration
  def change
    remove_column :contacts, :source
  end
end
