class LeaderboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where('points > 0')
                 .order(points: :desc)
                 .limit(100)

    @current_rank = @users.index { |u| u.id == current_user.id }&.+(1)

    # If current user has no points, still show their rank at the bottom
    if @current_rank.nil? && current_user.points.to_i == 0
      @current_rank = User.count
    end
  end
end