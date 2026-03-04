class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.string :name
      t.string :location_type
      t.string :address

      t.timestamps
    end
  end
end
