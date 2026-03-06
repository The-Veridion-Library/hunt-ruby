class UserBadge < ApplicationRecord
  belongs_to :user
  belongs_to :badge

  validates :awarded_at, presence: true
  validates :badge_id, uniqueness: { scope: :user_id, message: "already awarded" }

  before_create :set_awarded_at

  private

  def set_awarded_at
    self.awarded_at ||= Time.current
  end
end