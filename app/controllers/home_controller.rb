class HomeController < ApplicationController
  def index
    if user_signed_in?
      friend_ids = current_user.friendships.accepted.pluck(:friend_id)
      @feed = Find.where(user_id: friend_ids)
                  .includes(:user, :book)
                  .order(found_at: :desc)
                  .limit(20)

      @my_pending  = current_user.books.pending_review.order(created_at: :desc).limit(5)
      @my_rejected = current_user.books.rejected.order(updated_at: :desc).limit(3)

      @featured_books = Book.approved.order(created_at: :desc).limit(6)
    else
      @featured_books = Book.approved.order(created_at: :desc).limit(6)
    end
  end
end
