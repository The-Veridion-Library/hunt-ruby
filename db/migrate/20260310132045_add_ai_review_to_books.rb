class AddAiReviewToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :ai_review, :text
    add_column :books, :ai_reviewed_at, :datetime
  end
end
