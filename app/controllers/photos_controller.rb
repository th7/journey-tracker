class PhotosController < ApplicationController

	def index
		@user = current_user
		@photos = @user.photos
	end

	def create
		p params
		redirect_to '/photos'
	end
end