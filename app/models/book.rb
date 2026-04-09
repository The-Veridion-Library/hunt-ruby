class Book < ApplicationRecord
  belongs_to :user
  belongs_to :preferred_location, class_name: 'Location', optional: true
  has_many :labels, dependent: :destroy
  has_many :locations, through: :labels
  has_many :finds, dependent: :destroy
  has_many :hunt_books, dependent: :destroy
  has_many :hunts, through: :hunt_books

  SUBMISSION_STATUSES = %w[pending_review approved rejected].freeze
  CONDITIONS          = %w[like_new good acceptable poor].freeze
  # Book status (hidden/found) only matters once approved — default stays 'hidden'
  # but it's not shown to users until approved
  STATUSES = %w[hidden found].freeze

  validates :title,  presence: true
  validates :author, presence: true
  validates :isbn, presence: true, format: { with: /\A(?:\d{10}|\d{13})\z/, message: "must be 10 or 13 digits" }
  validates :status, inclusion: { in: STATUSES }
  validates :submission_status, inclusion: { in: SUBMISSION_STATUSES }
  validates :book_condition, inclusion: { in: CONDITIONS }, allow_blank: true

  before_validation :normalize_isbn
  before_validation :set_defaults

  scope :approved,       -> { where(submission_status: 'approved') }
  scope :pending_review, -> { where(submission_status: 'pending_review') }
  scope :rejected,       -> { where(submission_status: 'rejected') }
  scope :flagged,        -> { where(flagged: true) }

  def approved?   = submission_status == 'approved'
  def pending?    = submission_status == 'pending_review'
  def rejected?   = submission_status == 'rejected'
  def ai_reviewed? = ai_reviewed_at.present?

  def condition_label
    { 'like_new' => 'Like New', 'good' => 'Good', 'acceptable' => 'Acceptable', 'poor' => 'Poor' }[book_condition] || book_condition.to_s.humanize
  end

  def submission_status_label
    submission_status&.humanize || 'Unknown'
  end

  private

  def normalize_isbn
    self.isbn = isbn.to_s.gsub(/\D/, '') if isbn.present?
  end

  def set_defaults
    # status reflects hide/found state, separate from submission pipeline
    self.status            ||= 'hidden'
    self.submission_status ||= 'pending_review'
  end
end