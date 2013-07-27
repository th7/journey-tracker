class TripsController < ApplicationController
    skip_before_filter :check_authorization, only: [:show]

  def index
    @user = current_user
    @trips = Trip.all
  end
  
  def show
    @user = current_user
    @trip = Trip.find(params[:id])
    @photos = @trip.photos.map{ |p| PhotoPresenter.new(p)}.sort {|a,b| a.date <=> b.date}
    session[:current_trip] = @trip.id

  end

  def edit
    @user = current_user
    @trip = Trip.find(params[:id])
    @trip_user = @trip.user
    @photos = @trip.photos
    
  end

  def destroy
    p params
    Trip.find(params["id"]).destroy
    redirect_to user_path(current_user)
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
