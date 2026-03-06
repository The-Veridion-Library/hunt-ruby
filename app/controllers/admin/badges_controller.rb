class Admin::BadgesController < Admin::BaseController
  before_action :set_badge, only: [:edit, :update, :destroy]

  def index
    @badges = Badge.order(:name)
  end

  def new
    @badge = Badge.new
  end

  def create
    @badge = Badge.new(badge_params)
    if @badge.save
      redirect_to admin_badges_path, notice: "Badge created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @badge.update(badge_params)
      redirect_to admin_badges_path, notice: "Badge updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @badge.destroy
    redirect_to admin_badges_path, notice: "Badge deleted."
  end

  private

  def set_badge
    @badge = Badge.find(params[:id])
  end

  def badge_params
    params.require(:badge).permit(:name, :description, :icon, :threshold, :badge_type)
  end
end