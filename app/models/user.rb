class User < ApplicationRecord
  ROLES = %w[user admin].freeze

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
  validates :role, inclusion: { in: ROLES }
  validates :public_id, presence: true, uniqueness: true

  before_create :set_defaults

  def admin?
    role == 'admin'
  end

  private

  def set_defaults
    self.points    ||= 0
    self.role      ||= 'user'
    self.public_id ||= generate_public_id
  end

  def generate_public_id
    loop do
      id = "user_#{SecureRandom.hex(8)}"
      break id unless User.exists?(public_id: id)
    end
  end
end