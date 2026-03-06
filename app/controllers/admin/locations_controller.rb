class Admin::LocationsController < Admin::BaseController
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  def index
    @locations = Location.order(:name)
    @locations = @locations.where(location_type: params[:type]) if params[:type].present?
  end

  def show
    @labels = @location.labels.includes(:book)
  end

  def edit; end

  def update
    if @location.update(location_params)
      redirect_to admin_location_path(@location), notice: "Location updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy
    redirect_to admin_locations_path, notice: "Location deleted."
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :location_type, :address_line_1, :address_line_2, :city, :state, :zip_code, :latitude, :longitude)
  end
end