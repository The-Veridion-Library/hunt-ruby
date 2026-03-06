class HomeController < ApplicationController
  def index
    if user_signed_in?
      friend_ids = current_user.friendships.accepted.pluck(:friend_id)
      @feed = Find.where(user_id: friend_ids)
                  .includes(:user, :book)
                  .order(found_at: :desc)
                  .limit(20)
    end
  end
end