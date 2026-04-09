class HuntParticipantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_hunt

  def create
    @hunt.refresh_status!

    if @hunt.ended?
      redirect_to hunt_path(@hunt), alert: 'This hunt has already ended.'
      return
    end

    participant = @hunt.hunt_participants.find_or_initialize_by(user: current_user)

    if participant.persisted?
      redirect_to hunt_path(@hunt), notice: 'You already joined this hunt.'
    elsif participant.save
      redirect_to hunt_path(@hunt), notice: "You're in! Hunt joined successfully."
    else
      redirect_to hunt_path(@hunt), alert: participant.errors.full_messages.to_sentence
    end
  end

  private

  def set_hunt
    @hunt = Hunt.find(params[:hunt_id])
  end
end
