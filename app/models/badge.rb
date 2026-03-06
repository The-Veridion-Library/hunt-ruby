class Badge < ApplicationRecord
  has_many :user_badges, dependent: :destroy
  has_many :users, through: :user_badges

  validates :name, presence: true, uniqueness: true
  validates :threshold, numericality: { greater_than: 0 }
  validates :badge_type, inclusion: { in: %w[finds hidden points] }
end