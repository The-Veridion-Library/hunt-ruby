class AddAiReviewToLocations < ActiveRecord::Migration[8.1]
  def change
    add_column :locations, :ai_review, :text
    add_column :locations, :ai_reviewed_at, :datetime
  end
end
