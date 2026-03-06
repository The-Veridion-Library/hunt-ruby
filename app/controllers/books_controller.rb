class BooksController < ApplicationController
  before_action :authenticate_user!

  def index
    @books = Book.includes(:user, :labels).order(created_at: :desc)
  end

  def new
    @book = Book.new
    @locations = Location.all.order(:name)
  end

  def create
    @book = current_user.books.build(book_params)

    if @book.save
      label = Label.create!(
        book: @book,
        location_id: params[:location_id],
        user: current_user
      )
      redirect_to book_path(@book), notice: "Book hidden! Your QR code is ready to print."
    else
      @locations = Location.all.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @book = Book.find(params[:id])
    @label = @book.labels.active.last
    if @label
      qr = RQRCode::QRCode.new(scan_find_url(@label.qr_code))
      @qr_svg = qr.as_svg(
        offset: 0,
        color: "000",
        shape_rendering: "crispEdges",
        module_size: 4,
        standalone: true
      )
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :isbn, :cover_image, :description)
  end
end