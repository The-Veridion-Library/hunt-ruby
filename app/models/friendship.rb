class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User', foreign_key: 'friend_id'

  validates :status, inclusion: { in: %w[pending accepted] }
  validates :friend_id, uniqueness: { scope: :user_id, message: "already added" }
  validate :cannot_friend_yourself

  scope :accepted, -> { where(status: 'accepted') }
  scope :pending, -> { where(status: 'pending') }

  before_create :set_default_status

  private

  def set_default_status
    self.status ||= 'pending'
  end

  def cannot_friend_yourself
    errors.add(:base, "You can't add yourself as a friend!") if user_id == friend_id
  end
end