class AddAccessCodeRedeemedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_code_redeemed, :boolean
  end
end
