class Book < ApplicationRecord
  belongs_to :user
  has_many :labels, dependent: :destroy
  has_many :locations, through: :labels
  has_many :finds, dependent: :destroy

  validates :title, presence: true
  validates :author, presence: true
  validates :status, inclusion: { in: %w[hidden found] }

  before_validation :set_default_status

  private

  def set_default_status
    self.status ||= 'hidden'
  end
end