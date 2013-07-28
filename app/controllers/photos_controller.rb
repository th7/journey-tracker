class PhotosController < ApplicationController

	def index
		@user = current_user
		@photos = @user.photos
	end

	def create
		@user = current_user
		p "======= PHOTO PARAMS ==============="
		p params["url"]
		p params["filetype"]

		if ["image/jpeg","image/jpg"].include?(params["filetype"])
			new_photo = @user.photos.find_or_initialize_by_url(url: params["url"])
			new_photo.save
			get_exif_data(new_photo)
		end

		redirect_to photos_path
	end

	def show
	end

end