class Admin::HuntsController < Admin::BaseController
  before_action :set_hunt, only: [:show, :destroy, :set_status, :recalculate_scores, :award_winner_badge]

  def index
    Hunt.find_each(&:refresh_status!)

    @hunts = Hunt.includes(:user, :hunt_participants, :books).order(created_at: :desc)
    @hunts = @hunts.where(status: params[:status]) if params[:status].present?

    @active_count = Hunt.where(status: 'active').count
    @upcoming_count = Hunt.where(status: 'upcoming').count
    @ended_count = Hunt.where(status: 'ended').count
  end

  def show
    @hunt.refresh_status!
    @hunt.recalculate_scores!

    @leaderboard = @hunt.leaderboard
    @hunt_books = @hunt.books.order(:title)
  end

  def set_status
    new_status = params[:status].to_s

    unless Hunt::STATUSES.include?(new_status)
      redirect_back fallback_location: admin_hunt_path(@hunt), alert: 'Invalid hunt status.'
      return
    end

    @hunt.update!(status: new_status)
    redirect_back fallback_location: admin_hunt_path(@hunt), notice: "Hunt status updated to #{new_status}."
  end

  def recalculate_scores
    @hunt.recalculate_scores!
    redirect_back fallback_location: admin_hunt_path(@hunt), notice: 'Hunt scores recalculated.'
  end

  def award_winner_badge
    @hunt.refresh_status!

    unless @hunt.ended?
      redirect_back fallback_location: admin_hunt_path(@hunt), alert: 'Winner badge can only be awarded once the hunt has ended.'
      return
    end

    @hunt.recalculate_scores!
    @hunt.award_winner_badge!
    redirect_back fallback_location: admin_hunt_path(@hunt), notice: 'Winner badge processed.'
  end

  def destroy
    title = @hunt.title
    @hunt.destroy

    AuditLogService.log(
      user: current_user,
      action: 'deleted_hunt',
      resource: @hunt,
      details: { title: title },
      request: request
    )

    redirect_to admin_hunts_path, notice: 'Hunt deleted.'
  end

  private

  def set_hunt
    @hunt = Hunt.find(params[:id])
  end
end
