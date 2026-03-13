class AddMaturityRatingToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :maturity_rating, :string
  end
end
