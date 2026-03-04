class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :username, :string
    add_column :users, :avatar, :string
    add_column :users, :bio, :text
    add_column :users, :points, :integer
  end
end
