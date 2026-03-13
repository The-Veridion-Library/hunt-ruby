class Api::StatsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def index
    render json: {
      total_books:     Book.approved.count,
      total_finds:     Find.count,
      total_locations: Location.partners.count,
      total_users:     User.count
    }
  end
end
