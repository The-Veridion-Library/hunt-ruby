class Admin::DashboardController < Admin::BaseController
  def index
    @stats = {
      total_users:      User.count,
      new_users_week:   User.where(created_at: 1.week.ago..).count,
      total_books:      Book.count,
      books_hidden:     Book.where(status: 'hidden').count,
      books_found:      Book.where(status: 'found').count,
      total_finds:      Find.count,
      finds_today:      Find.where(found_at: Time.zone.today.all_day).count,
      finds_week:       Find.where(found_at: 1.week.ago..).count,
      labels_by_status: Label.group(:status).count,
      locations_by_type: Location.group(:location_type).count
    }

    @recent_finds    = Find.includes(:user, :book).order(found_at: :desc).limit(10)
    @recent_users    = User.order(created_at: :desc).limit(5)
    @recent_books    = Book.includes(:user).order(created_at: :desc).limit(5)
  end
end