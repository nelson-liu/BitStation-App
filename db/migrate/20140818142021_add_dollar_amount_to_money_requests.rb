class AddDollarAmountToMoneyRequests < ActiveRecord::Migration
  def change
    add_column :money_requests, :dollar_amount, :decimal
  end
end
