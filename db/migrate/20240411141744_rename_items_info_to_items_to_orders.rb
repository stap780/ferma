class RenameItemsInfoToItemsToOrders < ActiveRecord::Migration[7.1]
  def change
    rename_column :orders, :items_info, :items
  end
end
