class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @profile_user = User.find_by!(username: params[:username])
    @finds        = @profile_user.finds.includes(:book).order(found_at: :desc)
    @hidden_books = @profile_user.books.order(created_at: :desc)
    @badges       = @profile_user.badges
    @points       = @profile_user.points.to_i
  end
end