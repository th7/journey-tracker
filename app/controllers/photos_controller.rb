class PhotosController < ApplicationController

	def index
		@user = current_user
		@trip = Trip.find(session[:current_trip])
		@photos = @trip.photos
	end

	def create
		@trip = Trip.find(session[:current_trip])
		p "======= PHOTO PARAMS ==============="
		p params["url"]
		p params["filetype"]

		if ["image/jpeg","image/jpg"].include?(params["filetype"])
			new_photo = @trip.photos.find_or_initialize_by_url(url: params["url"])
			new_photo.save
			# get_exif_data(new_photo)
		end

		redirect_to photos_path
	end

	def show
	end

end