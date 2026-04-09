class Hunt < ApplicationRecord
  belongs_to :user

  has_many :hunt_books, dependent: :destroy
  has_many :books, through: :hunt_books

  has_many :hunt_participants, dependent: :destroy
  has_many :participants, through: :hunt_participants, source: :user

  STATUSES = %w[upcoming active ended].freeze

  validates :title, :start_date, :end_date, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :end_after_start
  validate :must_have_books

  before_validation :set_status_from_dates

  scope :upcoming, -> { where(status: 'upcoming').order(start_date: :asc) }
  scope :active, -> { where(status: 'active').order(start_date: :asc) }
  scope :ended, -> { where(status: 'ended').order(end_date: :desc) }

  def upcoming?
    status == 'upcoming'
  end

  def active?
    status == 'active'
  end

  def ended?
    status == 'ended'
  end

  def refresh_status!
    new_status = status_for_time(Time.current)
    update_column(:status, new_status) if persisted? && status != new_status
    self.status = new_status
  end

  def finds_scope
    Find.where(book_id: books.select(:id), found_at: start_date..end_date)
  end

  def recalculate_scores!
    scores = finds_scope.group(:user_id).sum(:points_awarded)

    hunt_participants.find_each do |participant|
      participant.update_column(:score, scores[participant.user_id].to_i)
    end
  end

  def leaderboard
    hunt_participants.includes(:user).order(score: :desc, created_at: :asc)
  end

  def award_winner_badge!
    return unless ended?
    return if winner_badge_awarded_at.present?

    winner = leaderboard.first
    return if winner.nil? || winner.score.to_i <= 0

    badge = Badge.find_or_create_by!(name: "Hunt Champion: #{title.to_s.truncate(40)}") do |b|
      b.badge_type = 'manual'
      b.description = "Winner of the hunt '#{title}'"
      b.icon = '🏆'
      b.seeded = false
    end

    UserBadge.find_or_create_by!(user: winner.user, badge: badge) do |user_badge|
      user_badge.awarded_at = Time.current
    end

    update_column(:winner_badge_awarded_at, Time.current)
  end

  private

  def set_status_from_dates
    return if start_date.blank? || end_date.blank?

    self.status = status_for_time(Time.current)
  end

  def status_for_time(reference_time)
    return 'upcoming' if reference_time < start_date
    return 'ended' if reference_time > end_date

    'active'
  end

  def end_after_start
    return if start_date.blank? || end_date.blank?
    return if end_date > start_date

    errors.add(:end_date, 'must be after start date')
  end

  def must_have_books
    errors.add(:base, 'Select at least one book for this hunt') if hunt_books.empty?
  end
end
