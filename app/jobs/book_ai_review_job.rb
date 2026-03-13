# app/jobs/book_ai_review_job.rb
class BookAiReviewJob < ApplicationJob
  queue_as :default

  # Retry up to 3 times on timeout, with increasing delays
  retry_on Net::ReadTimeout,  wait: :polynomially_longer, attempts: 3
  retry_on Net::OpenTimeout,  wait: :polynomially_longer, attempts: 3
  retry_on StandardError,     wait: 30.seconds,           attempts: 2

  def perform(book_id)
    book = Book.find_by(id: book_id)
    return unless book

    BookAiReviewService.new(book).call
  end
end