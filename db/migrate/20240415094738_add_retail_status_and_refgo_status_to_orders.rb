class AddRetailStatusAndRefgoStatusToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :retail_status, :string
    add_column :orders, :refgo_status, :string
  end
end
