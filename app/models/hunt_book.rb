class HuntBook < ApplicationRecord
  belongs_to :hunt
  belongs_to :book

  validates :book_id, uniqueness: { scope: :hunt_id }
  validate :book_must_have_placed_label

  private

  def book_must_have_placed_label
    return if book&.labels&.placed&.exists?

    errors.add(:book, 'must have at least one placed label to be included in a hunt')
  end
end
