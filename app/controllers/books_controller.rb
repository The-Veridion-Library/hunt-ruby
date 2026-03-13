class BooksController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:mine].present? && user_signed_in?
      @books      = current_user.books.includes(:labels).order(created_at: :desc)
      @page_title = "My Books"
    else
      @books      = Book.approved.includes(:user, :labels).order(created_at: :desc)
      @page_title = "Book Catalog"
    end
    @my_pending  = current_user.books.pending_review.order(created_at: :desc)
    @my_rejected = current_user.books.rejected.order(created_at: :desc)
  end

  # Step 1: Enter ISBN
  def new
    session.delete(:book_prefill) if params[:reset]
  end

  # Step 1 → Step 2: Look up ISBN, store in session, render prefill form
  def isbn_lookup
    isbn = params[:isbn].to_s.gsub(/\D/, '')

    if isbn.length != 13 && isbn.length != 10
      flash.now[:alert] = "Please enter a valid ISBN-10 or ISBN-13."
      return render :new, status: :unprocessable_entity
    end

    data = fetch_book_data(isbn)

    session[:book_prefill] = {
      'isbn'            => isbn,
      'title'           => data[:title],
      'author'          => data[:author],
      'cover'           => data[:cover],
      'maturity_rating' => data[:maturity_rating]
    }

    @prefill   = session[:book_prefill]
    @book      = Book.new(title: @prefill['title'], author: @prefill['author'], isbn: @prefill['isbn'])
    @locations = Location.partners.order(:name)
    @ol_found  = data[:found]

    render :new_details
  end

  # Step 2: Full submission form
  def new_details
    prefill = session[:book_prefill]
    unless prefill
      redirect_to new_book_path
      return
    end
    @prefill   = prefill
    @book      = Book.new(title: prefill['title'], author: prefill['author'], isbn: prefill['isbn'])
    @locations = Location.partners.order(:name)
    @ol_found  = prefill['title'].present?
  end

  def create
    @book = current_user.books.build(book_params)
    # Carry maturity_rating from prefill if not in params
    if @book.maturity_rating.blank? && session.dig(:book_prefill, 'maturity_rating').present?
      @book.maturity_rating = session[:book_prefill]['maturity_rating']
    end

    if @book.save
      session.delete(:book_prefill)
      BookAiReviewJob.perform_later(@book.id)
      redirect_to book_path(@book), notice: "Thanks! Your submission is under review. We'll notify you once it's approved."
    else
      @prefill   = session[:book_prefill] || {}
      @locations = Location.partners.order(:name)
      render :new_details, status: :unprocessable_entity
    end
  end

  def show
    @book = Book.find(params[:id])
    unless @book.approved? || @book.user == current_user || current_user.admin?
      redirect_to books_path, alert: "That book isn't available."
      return
    end

    if @book.approved? && @book.user == current_user
      @label = @book.labels.active.last
      if @label
        qr = RQRCode::QRCode.new(scan_find_url(@label.qr_code))
        @qr_svg = qr.as_svg(
          offset: 0, color: "000",
          shape_rendering: "crispEdges",
          module_size: 4, standalone: true
        )
      end
    end

    # Compute auto-delete countdown for rejected books
    if @book.rejected? && @book.user == current_user
      rejected_at   = @book.updated_at
      deletes_at    = rejected_at + 48.hours
      @hours_until_delete = ((deletes_at - Time.current) / 1.hour).ceil
      @deletes_at   = deletes_at
    end
  end

  def report
    @book = Book.find(params[:id])
    @book.update!(flagged: true)
    redirect_to book_path(@book), notice: "Book reported. Our team will review it."
  end

  private

  def book_params
    params.require(:book).permit(
      :title, :author, :isbn,
      :book_condition,
      :front_cover, :back_cover,
      :submission_notes,
      :preferred_location_id,
      :maturity_rating
    )
  end

  # Queries both Open Library and Google Books, merges best results
  def fetch_book_data(isbn)
    ol     = fetch_open_library(isbn)
    google = fetch_google_books(isbn)

    # Prefer Google for title/author if available, OL as fallback
    title  = google[:title].presence  || ol[:title]
    author = google[:author].presence || ol[:author]
    cover  = ol[:cover].presence      || google[:cover]  # OL covers tend to be cleaner

    {
      found:           (ol[:found] || google[:found]),
      title:           title,
      author:          author,
      cover:           cover,
      maturity_rating: google[:maturity_rating]
    }
  end

  def fetch_open_library(isbn)
    require 'net/http'
    require 'json'

    uri      = URI("https://openlibrary.org/api/books?bibkeys=ISBN:#{isbn}&format=json&jscmd=data")
    http     = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = true
    http.open_timeout = 5
    http.read_timeout = 8

    response = http.get(uri.request_uri)
    parsed   = JSON.parse(response.body)
    data     = parsed["ISBN:#{isbn}"]

    return { found: false, title: nil, author: nil, cover: nil } unless data

    {
      found:  true,
      title:  data['title'].presence,
      author: data.dig('authors', 0, 'name').presence || data['by_statement'].presence,
      cover:  data.dig('cover', 'medium') || data.dig('cover', 'large') || data.dig('cover', 'small')
    }
  rescue => e
    Rails.logger.warn "[OpenLibrary] Lookup failed for #{isbn}: #{e.message}"
    { found: false, title: nil, author: nil, cover: nil }
  end

  def fetch_google_books(isbn)
    require 'net/http'
    require 'json'

    uri      = URI("https://www.googleapis.com/books/v1/volumes?q=isbn:#{isbn}&maxResults=1")
    http     = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = true
    http.open_timeout = 5
    http.read_timeout = 8

    response = http.get(uri.request_uri)
    parsed   = JSON.parse(response.body)
    item     = parsed.dig('items', 0, 'volumeInfo')

    return { found: false, title: nil, author: nil, cover: nil, maturity_rating: nil } unless item

    {
      found:           true,
      title:           item['title'].presence,
      author:          item['authors']&.first.presence,
      cover:           item.dig('imageLinks', 'thumbnail')&.gsub('http://', 'https://'),
      maturity_rating: item['maturityRating']  # e.g. "NOT_MATURE", "MATURE"
    }
  rescue => e
    Rails.logger.warn "[GoogleBooks] Lookup failed for #{isbn}: #{e.message}"
    { found: false, title: nil, author: nil, cover: nil, maturity_rating: nil }
  end
end
