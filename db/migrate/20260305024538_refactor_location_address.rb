class RefactorLocationAddress < ActiveRecord::Migration[8.1]
  def change
    remove_column :locations, :address, :string

    add_column :locations, :address_line_1, :string
    add_column :locations, :address_line_2, :string
    add_column :locations, :city, :string
    add_column :locations, :state, :string
    add_column :locations, :zip_code, :string
  end
end