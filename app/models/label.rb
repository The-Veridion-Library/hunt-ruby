class Label < ApplicationRecord
  belongs_to :book
  belongs_to :location
  belongs_to :user

  has_many :finds, dependent: :destroy

  STATUSES = %w[created printed placed invalidated].freeze

  scope :active, -> { where(status: 'placed') }
  scope :created, -> { where(status: 'created') }
  scope :printed, -> { where(status: 'printed') }
  scope :placed, -> { where(status: 'placed') }
  scope :invalidated, -> { where(status: 'invalidated') }

  validates :qr_code, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  before_validation :set_default_status
  before_validation :generate_qr_code

  private

  def set_default_status
    self.status ||= 'created'
  end

  def generate_qr_code
    self.qr_code ||= SecureRandom.hex(12)
  end
end