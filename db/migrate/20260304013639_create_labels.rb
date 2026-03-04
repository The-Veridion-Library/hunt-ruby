class CreateLabels < ActiveRecord::Migration[8.1]
  def change
    create_table :labels do |t|
      t.references :book, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :qr_code
      t.string :status

      t.timestamps
    end
  end
end
