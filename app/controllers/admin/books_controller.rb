class Admin::BooksController < Admin::BaseController
  before_action :set_book, only: [:show, :edit, :update, :destroy]

  def index
    @books = Book.includes(:user).order(created_at: :desc)
    @books = @books.where(status: params[:status]) if params[:status].present?
  end

  def show
    @labels = @book.labels.includes(:location)
    @finds  = @book.finds.includes(:user)
  end

  def edit; end

  def update
    if @book.update(book_params)
      redirect_to admin_book_path(@book), notice: "Book updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to admin_books_path, notice: "Book deleted."
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :author, :isbn, :status, :cover_image)
  end
end