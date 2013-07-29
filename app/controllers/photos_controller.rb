class PhotosController < ApplicationController
require 'open-uri'
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
			# get_exif_data(new_photo)
			new_photo.save
		end

		redirect_to photos_path
	end

	def show
	end
  
  def destroy
    Photo.find(params['id']).destroy
    @trip = Trip.find(session[:current_trip])
    
    redirect_to edit_trip_path(@trip.id)
  end

 
end
