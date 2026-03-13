# app/jobs/location_ai_review_job.rb
class LocationAiReviewJob < ApplicationJob
  queue_as :default

  retry_on Net::ReadTimeout, wait: :polynomially_longer, attempts: 3
  retry_on Net::OpenTimeout, wait: :polynomially_longer, attempts: 3
  retry_on StandardError,    wait: 30.seconds,           attempts: 2

  def perform(location_id)
    location = Location.find_by(id: location_id)
    return unless location

    LocationAiReviewService.new(location).call
  end
end
