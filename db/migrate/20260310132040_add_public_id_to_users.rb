class AddPublicIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :public_id, :string
    add_index :users, :public_id, unique: true
  end
end
