class CreateThings < ActiveRecord::Migration[5.0]
  def change
    create_table :things do |t|
      t.string :name
      t.string :thingname

      t.timestamps
    end
  end
end
