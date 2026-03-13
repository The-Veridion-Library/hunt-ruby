# app/jobs/rejected_book_cleanup_job.rb
# Deletes rejected books that have been rejected for more than 48 hours.
# Schedule this to run hourly via config/recurring.yml (Solid Queue) or a cron.
class RejectedBookCleanupJob < ApplicationJob
  queue_as :default

  def perform
    cutoff = 48.hours.ago
    stale  = Book.rejected.where("updated_at < ?", cutoff)
    count  = stale.count
    stale.destroy_all
    Rails.logger.info "[RejectedBookCleanupJob] Deleted #{count} stale rejected book(s)."
  end
end
