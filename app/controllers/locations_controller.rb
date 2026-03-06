class LocationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @locations = Location.all.order(:name)
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)

    if @location.latitude.to_f.zero? || @location.longitude.to_f.zero?
      coords = geocode_address(@location.full_address)
      if coords
        @location.latitude = coords[:lat]
        @location.longitude = coords[:lng]
      else
        flash.now[:alert] = "Could not auto-detect coordinates — please enter them manually."
      end
    end

    if @location.save
      redirect_to locations_path, notice: "Location added! Coordinates: #{@location.latitude}, #{@location.longitude}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def location_params
    params.require(:location).permit(
      :name, :location_type,
      :address_line_1, :address_line_2,
      :city, :state, :zip_code,
      :latitude, :longitude
    )
  end

  def geocode_address(address)
    require 'net/http'
    require 'json'

    query = URI.encode_www_form(q: address, format: 'json', limit: 1)
    uri = URI("https://nominatim.openstreetmap.org/search?#{query}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    request['User-Agent'] = 'TheVeridionBookHunt/1.0'

    response = http.request(request)
    results = JSON.parse(response.body)

    if results.any?
      { lat: results[0]['lat'].to_f, lng: results[0]['lon'].to_f }
    else
      nil
    end
  rescue => e
    Rails.logger.error "Geocoding failed: #{e.message}"
    nil
  end
end