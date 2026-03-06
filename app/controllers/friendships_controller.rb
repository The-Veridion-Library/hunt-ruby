class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @friends = current_user.friendships.accepted.includes(:friend)
  end

  def create
    friend = User.find(params[:friend_id])

    if friend == current_user
      redirect_back fallback_location: root_path, alert: "You can't add yourself!" and return
    end

    if Friendship.exists?(user: current_user, friend: friend)
      redirect_back fallback_location: root_path, alert: "Friend request already sent!" and return
    end

    Friendship.create!(user: current_user, friend: friend, status: 'pending')
    redirect_back fallback_location: root_path, notice: "Friend request sent to #{friend.username}!"
  end

  def accept
    @friendship = Friendship.find(params[:id])

    @friendship.update!(status: 'accepted')

    # Create the reciprocal friendship
    Friendship.find_or_create_by!(user: @friendship.friend, friend: current_user) do |f|
      f.status = 'accepted'
    end

    redirect_to friendship_requests_path, notice: "You are now friends with #{@friendship.user.username}!"
  end

  def destroy
    @friendship = current_user.friendships.find(params[:id])
    @friendship.destroy
    redirect_back fallback_location: friendships_path, notice: "Friend removed."
  end

  def requests
    @pending = Friendship.where(friend: current_user, status: 'pending').includes(:user)
  end
end