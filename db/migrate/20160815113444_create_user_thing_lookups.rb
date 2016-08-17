class CreateUserThingLookups < ActiveRecord::Migration[5.0]
  def change
    create_table :user_thing_lookups do |t|
      t.integer :user_id
      t.integer :thing_id

      t.timestamps
    end
  end
end
