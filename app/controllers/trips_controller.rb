class TripsController < ApplicationController
  def index

  end
  
  def show
    @user = current_user
    @trip = Trip.find(params[:id])
    @photos = @trip.photos
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
