class PhotosController < ApplicationController
	def index
		@user = current_user
		@trip = Trip.find(session[:current_trip])
		@photos = @trip.photos
	end

	def new
		# @trip = Trip.find(session[:current_trip])
	end

	def create
		@trip = Trip.find(session[:current_trip])
		new_photo = @trip.photos.find_or_initialize_by_url(url: params["url"].gsub!(/(\.)([^\.]*)\z/,'h\1\2'))
		new_photo.update_attributes(date: DateTime.strptime(params["date"],"%Y:%m:%d %T").to_i)

		if params["lon"]
			new_photo.set_gps_as_decimal(params["lat"],params["latRef"])
			new_photo.set_gps_as_decimal(params["lon"],params["lonRef"])
		end

		redirect_to photo_path(new_photo)

	end

	def show
		@photo = Photo.find(params[:id])
	end

	def update
		unless params['photo_address'] == "" 
			formatted_address = params['photo_address'].gsub(/\s/, "+")
			url = "http://maps.googleapis.com/maps/api/geocode/json?address="+formatted_address+"&sensor=true"
      file = open(url)
      read_data = file.read
      data = JSON.parse(read_data)
      p params['photo_address']
      latitude = data['results'][0]['geometry']['location']['lat']
      longitude = data['results'][0]['geometry']['location']['lng']
		end
		@temp_photo = Photo.find(params['photo_id'])
		@temp_photo.update_attributes(caption: params["photo_caption"],date: params["photo_date"].to_datetime.to_i)
    

    if latitude
			@temp_photo.update_attributes(lat: latitude, long: longitude)
    else
    	@temp_photo.update_attributes(lat: params["photo_lat"],long: params["photo_long"])
		end

    if request.xhr?
    	@trip = @temp_photo.trip
    	render partial: "trips/photo_details", :locals => {:photo => @temp_photo}
    end

	end
  
  def destroy
    Photo.find(params['id']).destroy
    @trip = Trip.find(session[:current_trip])    
    redirect_to edit_trip_path(@trip.id)
  end

end


