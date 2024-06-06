class AddRetailNumColumnToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :retail_num, :string
  end
end
