class CreateRetails < ActiveRecord::Migration[7.1]
  def change
    create_table :retails do |t|
      t.string :api_link
      t.string :api_key

      t.timestamps
    end
  end
end
