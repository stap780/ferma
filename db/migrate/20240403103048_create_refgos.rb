class CreateRefgos < ActiveRecord::Migration[7.1]
  def change
    create_table :refgos do |t|
      t.string :api_link
      t.string :api_login
      t.string :api_password

      t.timestamps
    end
  end
end
