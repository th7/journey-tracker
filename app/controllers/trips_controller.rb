class TripsController < ApplicationController
    skip_before_filter :check_authorization, only: [:show]

  def index
    @trips = Trip.all
  end
  
  def show
    @user = current_user
    @trip = Trip.find(params[:id])
    @photos = @trip.photos.map{ |p| PhotoPresenter.new(p)}
    session[:current_trip] = @trip.id

  end

  def destroy
  end

  def create
    p "========= DATE FORM ================"
    p params
    @user = current_user
    new_trip = @user.trips.create(params[:trip])
    redirect_to trip_path(new_trip)
  end

  def new
    @trip = Trip.new
  end

end
