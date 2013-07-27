class UsersController < ApplicationController
	def index
		@users = User.all
	end

	def show
		@user =User.find(session[:user_id])
    @user_on_page = User.find(params[:id])
    @trips =@user_on_page.trips
	end

end
