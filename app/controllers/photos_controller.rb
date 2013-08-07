class PhotosController < ApplicationController
	def index
    @trip = current_user.trips.find_by_slug(params[:trip_id])
    redirect_to root_path unless @trip
	end

	def new
		@trip = current_user.trips.find_by_slug(params[:trip_id])
    redirect_to root_path unless @trip
	end

	def create
    trip = current_user.trips.find_by_slug(params[:trip_id])
		new_photo = trip.photos.find_or_initialize_by_url(url: params[:photo][:url])
    new_photo.update_attributes(params[:photo])

		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def show
		@photo = Photo.find(params[:id])
	end

	def update
    p params
    unless params[:photo_address].nil? || params[:photo_address] == ""
      formatted_address = params[:photo_address].gsub(/\s/, "+")
      url = "http://maps.googleapis.com/maps/api/geocode/json?address="+formatted_address+"&sensor=true"
      file = open(url)
      read_data = file.read
      data = JSON.parse(read_data)

      params[:photo][:lat] = data['results'][0]['geometry']['location']['lat']
      params[:photo][:long] = data['results'][0]['geometry']['location']['lng']
    end
      params[:photo][:date] = params[:photo][:date].to_datetime.to_i if params[:photo][:date]

    @trip = current_user.trips.find_by_slug(params[:trip_id])
    if @trip
      photo = @trip.photos.find_by_id(params[:photo][:id])
      photo.update_attributes(params[:photo]) if photo
    end

    if request.xhr?
    	render partial: "trips/photo_details", :locals => {:photo => photo}
    else
      render :nothing => true, :status => 200, :content_type => 'text/html'
    end
	end

  def destroy
    photo = current_user.photos.find_by_id(params[:id])
    if photo
      trip_id = photo.trip_id
      photo.destroy
      if request.xhr?
        render :nothing => true, :status => 200, :content_type => 'text/html'
      else
        redirect_to edit_trip_path(trip_id)
      end
    else
      redirect_to root_path
    end
  end

end


