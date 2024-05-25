class ChangeTypeItemColumnToOrders < ActiveRecord::Migration[7.1]

  def up
    change_table :orders do |t|
      t.change :items, :string, array: true, default: [], using: "(string_to_array(items, ','))"
    end
  end

  def down
    change_table :orders do |t|
      t.change :items, :string
    end
  end

end
