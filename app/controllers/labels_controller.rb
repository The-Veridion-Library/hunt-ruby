class LabelsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_label, only: [:show, :edit, :update]

  def index
    @labels = current_user.labels.includes(:book, :location).order(created_at: :desc)
  end

  def new
    @label = Label.new
    @books = current_user.books.order(:title)
    @locations = Location.all.order(:name)
  end

  def create
    @label = Label.new(label_params)
    @label.user = current_user

    if @label.save
      redirect_to label_path(@label), notice: "Label created! Ready to print."
    else
      @books = current_user.books.order(:title)
      @locations = Location.all.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    qr = RQRCode::QRCode.new(scan_find_url(@label.qr_code))
    @qr_svg = qr.as_svg(
      offset: 0,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 4,
      standalone: true
    )
  end

  def edit
    @books = current_user.books.order(:title)
    @locations = Location.all.order(:name)
  end

  def update
    if @label.update(label_params)
      redirect_to label_path(@label), notice: "Label updated!"
    else
      @books = current_user.books.order(:title)
      @locations = Location.all.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_label
    @label = current_user.labels.find(params[:id])
  end

  def label_params
    params.require(:label).permit(:book_id, :location_id, :status)
  end
end