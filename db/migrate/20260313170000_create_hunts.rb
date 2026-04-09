class CreateHunts < ActiveRecord::Migration[8.1]
  def change
    create_table :hunts do |t|
      t.string :title, null: false
      t.text :description
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.string :status, null: false, default: "upcoming"
      t.datetime :winner_badge_awarded_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :hunts, :status
    add_index :hunts, :start_date
    add_index :hunts, :end_date

    create_table :hunt_books do |t|
      t.references :hunt, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end

    add_index :hunt_books, [:hunt_id, :book_id], unique: true

    create_table :hunt_participants do |t|
      t.references :hunt, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :score, null: false, default: 0

      t.timestamps
    end

    add_index :hunt_participants, [:hunt_id, :user_id], unique: true
  end
end
