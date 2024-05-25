class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.integer :retail_uid
      t.integer :retail_client_uid
      t.string :items_info
      t.string :refgo_num
      t.decimal :sum
      t.decimal :delivery_price
      t.boolean :prepaid
      t.string :storage_code

      t.timestamps
    end
  end
end
