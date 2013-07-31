class UsersController < ApplicationController
	def index
		@users = User.all
	end

	def show
		@user = current_user
    @user_on_page = User.find(params[:id])
		if @user == @user_on_page && @trips = @user_on_page.trips.all
			redirect_to new_trip_path
		end
	end

end
