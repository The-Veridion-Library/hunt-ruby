class Admin::JobsController < Admin::BaseController
  def index
    @solid_queue_available = solid_queue_available?

    if @solid_queue_available
      @ready     = SolidQueue::ReadyExecution.includes(:job).order(created_at: :desc).limit(50)
      @claimed   = SolidQueue::ClaimedExecution.includes(:job).order(created_at: :desc).limit(50)
      @failed    = SolidQueue::FailedExecution.includes(:job).order(created_at: :desc).limit(100)
      @scheduled = SolidQueue::ScheduledExecution.includes(:job).order(:scheduled_at).limit(50)

      @stats = {
        ready:           SolidQueue::ReadyExecution.count,
        claimed:         SolidQueue::ClaimedExecution.count,
        failed:          SolidQueue::FailedExecution.count,
        scheduled:       SolidQueue::ScheduledExecution.count,
        completed_today: SolidQueue::Job.where(finished_at: Time.current.beginning_of_day..).count
      }
    end
  end

  def clear_failed
    return redirect_to admin_jobs_path, alert: "Solid Queue not available." unless solid_queue_available?
    count = SolidQueue::FailedExecution.count
    SolidQueue::FailedExecution.joins(:job).each { |fe| fe.job.destroy }
    redirect_to admin_jobs_path, notice: "Cleared #{count} failed job#{'s' unless count == 1}."
  end

  private

  def solid_queue_available?
    # Use ActiveRecord's connection table check rather than raw SQL — works
    # reliably across PostgreSQL schemas and doesn't depend on information_schema.
    ActiveRecord::Base.connection.table_exists?('solid_queue_jobs')
  rescue => e
    Rails.logger.warn "[Admin::JobsController] Solid Queue check failed: #{e.message}"
    false
  end
end
