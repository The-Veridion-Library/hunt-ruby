class Find < ApplicationRecord
  belongs_to :book
  belongs_to :user
  belongs_to :label

  validates :found_at, presence: true
  validates :points_awarded, numericality: { greater_than_or_equal_to: 0 }
  validate :cannot_find_own_book
  validate :cannot_find_twice

  before_create :set_defaults

  private

  def set_defaults
    self.found_at ||= Time.current
    self.points_awarded ||= 10
  end

  def cannot_find_own_book
    errors.add(:base, "You can't find your own book!") if book&.user_id == user_id
  end

  def cannot_find_twice
    if Find.exists?(book: book, user: user)
      errors.add(:base, "You've already found this book!")
    end
  end
end