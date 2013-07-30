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
		p "======= PHOTO PARAMS ==============="
		p params
		# {"url"=>"http://i.imgur.com/5drf5AG.jpg", "date"=>"2013:05:04 09:56:14", "lat"=>"N", "lon"=>"E", "action"=>"create", "controller"=>"photos"}
		# {"url"=>"http://i.imgur.com/cabjMk2.jpg", "date"=>"2013:05:04 09:56:14", "lat"=>["21", "1.77", "0"], "lon"=>["105", "50.91", "0"], "action"=>"create", "controller"=>"photos"}
		# {"url"=>"http://i.imgur.com/fHHpwBj.jpg", "date"=>"2013:05:04 09:56:14", "lat"=>["21", "1.77", "0"], "lon"=>["105", "50.91", "0"], "latRef"=>"N", "lonRef"=>"E", "action"=>"create", "controller"=>"photos"}

		new_photo = @trip.photos.find_or_initialize_by_url(url: params["url"], date: params["date_created"].to_i)
		new_photo.save

		if params["lon"]
			new_photo.set_gps_as_decimal(params["lat"],params["latRef"])
			new_photo.set_gps_as_decimal(params["lon"],params["lonRef"])
		end

		redirect_to photo_path(new_photo)

	end

	def show
		@photo = Photo.find(params[:id])
	end
  
  def destroy
    Photo.find(params['id']).destroy
    @trip = Trip.find(session[:current_trip])    
    redirect_to edit_trip_path(@trip.id)
  end

end
