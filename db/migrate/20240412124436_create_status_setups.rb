class CreateStatusSetups < ActiveRecord::Migration[7.1]
  def change
    create_table :status_setups do |t|
      t.string :retail_status
      t.string :refgo_status

      t.timestamps
    end
  end
end
