class AddSubtotalToTransfers < ActiveRecord::Migration
  def change
  	add_column :transfers, :subtotal, :integer
  end
end
