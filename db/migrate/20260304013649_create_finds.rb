class CreateFinds < ActiveRecord::Migration[8.1]
  def change
    create_table :finds do |t|
      t.references :book, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :label, null: false, foreign_key: true
      t.string :photo
      t.datetime :found_at
      t.integer :points_awarded

      t.timestamps
    end
  end
end
