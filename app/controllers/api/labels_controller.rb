class Api::LabelsController < ApplicationController
  def index
    labels = Label.placed
                  .includes(:book, :location)
                  .order(created_at: :desc)

    render json: labels.map { |label|
      {
        id:            label.id,
        qr_code:       label.qr_code,
        book_title:    label.book.title,
        book_author:   label.book.author,
        location_name: label.location.name,
        location_type: label.location.location_type,
        location_addr: label.location.full_address,
        lat:           label.location.latitude&.to_f,
        lng:           label.location.longitude&.to_f,
        book_url:      "/books/#{label.book.id}"
      }
    }
  end
end