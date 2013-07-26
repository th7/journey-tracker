class TripController < ApplicationController
  def index
    @trips = current_user.trips if current_user
  end
  
  def show
    @trip = Trip.find(params[:trip_id])
  end

  def destroy
  end

  def create
  end

  def new
  end

end
