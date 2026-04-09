class HuntParticipant < ApplicationRecord
  belongs_to :hunt
  belongs_to :user

  validates :user_id, uniqueness: { scope: :hunt_id }
  validates :score, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_default_score

  def recalculate_score!
    update!(score: hunt.finds_scope.where(user_id: user_id).sum(:points_awarded).to_i)
  end

  private

  def set_default_score
    self.score ||= 0
  end
end
