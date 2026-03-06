class ChangeLabelsStatusDefault < ActiveRecord::Migration[8.1]
  def change
    change_column_default :labels, :status, from: nil, to: 'created'
  end
end