class CreateMeasures < ActiveRecord::Migration[5.0]
  def change
    create_table :measures do |t|
      t.text :title
      t.text :body
      t.timestamp :datetime
      t.text :name
      t.text :value
      t.text :thingname
      t.text :unit
      t.text :source
      t.text :comment
      t.boolean :active
      t.integer :thing_id

      t.timestamps
    end
  end
end
