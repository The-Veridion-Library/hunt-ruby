class CreateBadges < ActiveRecord::Migration[8.1]
  def change
    create_table :badges do |t|
      t.string :name
      t.text :description
      t.string :icon
      t.integer :threshold
      t.string :badge_type

      t.timestamps
    end
  end
end
