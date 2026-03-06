class FindsController < ApplicationController
  before_action :authenticate_user!

  def index
    @finds = current_user.finds.includes(:book, :label).order(found_at: :desc)
  end

  def scan
    @label = Label.find_by(qr_code: params[:qr_token])

    if @label.nil?
      redirect_to root_path, alert: "Invalid QR code!" and return
    end

    @book = @label.book

    if @book.user == current_user
      redirect_to root_path, alert: "You can't find your own book!" and return
    end

    if Find.exists?(book: @book, user: current_user)
      redirect_to root_path, alert: "You already found this book!" and return
    end

    if @label.status != 'placed'
      redirect_to root_path, alert: "This label is not active!" and return
    end
  end

  def new
    @label = Label.find_by(qr_code: params[:qr_token])
    redirect_to root_path, alert: "Invalid QR code!" if @label.nil?
  end

  def create
    @label = Label.find_by!(qr_code: params[:qr_token])
    @book = @label.book

    @find = Find.new(
      book: @book,
      user: current_user,
      label: @label,
      found_at: Time.current,
      points_awarded: 10,
      photo: params[:photo]
    )

    if @find.save
      current_user.increment!(:points, 10)
      BadgeAwarder.call(current_user)
      @book.update!(status: 'found')
      @label.update!(status: 'invalidated')
      redirect_to finds_path, notice: "🎉 Book found! +10 points added to your profile."
    else
      @label = @find.label
      render :scan, status: :unprocessable_entity
    end
  end
end