class TripsController < ApplicationController
    skip_before_filter :check_authorization, only: [:show]

  def index
    @trips = current_user.trips
  end

  def show
    @trip = Trip.find_by_slug(params[:id])
    @photos = @trip.photos.sort {|a,b| a.date <=> b.date}
    session[:current_trip] = @trip.id
  end

  def edit
    @trip = current_user.trips.find_by_slug(params[:id])
    if @trip
      session[:current_trip] = @trip.id
    else
      flash[:error] = "You don't have permissions to edit that trip"
      redirect_to root_path
    end
  end

  def destroy
    trip = current_user.trips.find_by_slug(params[:id])
    trip.destroy if trip
    redirect_to user_path(current_user)
  end

  def create
    new_trip = current_user.trips.create(params[:trip])
    if new_trip.valid?
      session[:current_trip] = new_trip.id
      redirect_to edit_trip_path(new_trip)
    else
      redirect_to new_trip_path, :error => new_trip.errors
    end
  end

  def new
    @trip = Trip.new
  end

  def update
    trip = current_user.trips.find_by_slug(params[:id])
    if trip
      trip.update_attributes(params[:trip])
      trip.photos.each do |photo|
        if photo.date > trip.end.to_i || photo.date < trip.start.to_i
           photo.destroy
        end
      end
      redirect_to edit_trip_path(trip)
    else
      redirect_to root_path
    end
  end


end
