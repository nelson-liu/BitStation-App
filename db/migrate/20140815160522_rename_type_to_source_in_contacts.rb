class RenameTypeToSourceInContacts < ActiveRecord::Migration
  def change
    rename_column :contacts, :type, :source
  end
end
