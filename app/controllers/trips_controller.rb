class TripsController < ApplicationController
  def index
    @trips = Trip.all
  end
  
  def show
    @user = current_user
    @trip = Trip.find(params[:id])

    # MOVE THIS TO PHOTO CONTROLLER?
    @photos = @trip.photos
    if @photos.empty?
      client = Instagram.client(:access_token => session[:access_token])
      client.user_recent_media.each do |photo|
        temp_photo = @trip.photos.find_or_initialize_by_url(caption: photo.caption.text, date: photo.caption.created_time.to_i, url:photo.images.standard_resolution.url)
        temp_photo.update_attributes(lat: photo.location.latitude, long: photo.location.longitude) if photo.location
        temp_photo.save!
      end
      @photos = @trip.photos
    end
  end

  def destroy
  end

  def create
    @user = current_user
    new_trip = @user.trips.create(params[:trip])
    redirect_to trip_path(new_trip)
  end

  def new
    @trip = Trip.new
  end

end
