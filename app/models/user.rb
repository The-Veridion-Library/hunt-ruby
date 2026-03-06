class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books, dependent: :destroy
  has_many :labels, dependent: :destroy
  has_many :finds, dependent: :destroy
  has_many :found_books, through: :finds, source: :book
  has_many :user_badges, dependent: :destroy
  has_many :badges, through: :user_badges
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 30 }
  validates :points, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_create :set_default_points

  private

  def set_default_points
    self.points ||= 0
  end
end