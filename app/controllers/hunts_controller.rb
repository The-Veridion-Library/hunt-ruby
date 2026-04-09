class HuntsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_hunt, only: [:show]

  def index
    Hunt.find_each(&:refresh_status!)

    @active_hunts = Hunt.active.includes(:user, :hunt_participants)
    @upcoming_hunts = Hunt.upcoming.includes(:user, :hunt_participants)
    @ended_hunts = Hunt.ended.includes(:user, :hunt_participants).limit(12)
  end

  def show
    @hunt.refresh_status!
    @hunt.recalculate_scores!
    @hunt.award_winner_badge!

    @leaderboard = @hunt.leaderboard
    @participant = @hunt.hunt_participants.find_by(user: current_user)
    @joined = @participant.present?

    @hunt_books = @hunt.books.includes(labels: :location).order(:title)

    @map_points = @hunt_books.filter_map do |book|
      label = book.labels.where(status: %w[placed invalidated]).order(updated_at: :desc).first
      location = label&.location
      next if location&.latitude.blank? || location&.longitude.blank?

      {
        title: book.title,
        author: book.author,
        location_name: location.name,
        latitude: location.latitude.to_f,
        longitude: location.longitude.to_f,
        book_url: Rails.application.routes.url_helpers.book_path(book)
      }
    end
  end

  def new
    @hunt = Hunt.new(
      start_date: Time.current.beginning_of_hour + 1.day,
      end_date: Time.current.beginning_of_hour + 8.days
    )
    @eligible_books = eligible_books
  end

  def create
    @hunt = current_user.hunts.build(hunt_params)
    selected_book_ids = Array(params.dig(:hunt, :book_ids)).reject(&:blank?)
    selected_book_ids.each { |book_id| @hunt.hunt_books.build(book_id: book_id) }

    if @hunt.save
      redirect_to hunt_path(@hunt), notice: "Hunt created successfully. Let the chase begin!"
    else
      @eligible_books = eligible_books
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_hunt
    @hunt = Hunt.find(params[:id])
  end

  def hunt_params
    params.require(:hunt).permit(:title, :description, :start_date, :end_date)
  end

  def eligible_books
    Book.approved.joins(:labels).merge(Label.placed).distinct.order(:title)
  end
end
