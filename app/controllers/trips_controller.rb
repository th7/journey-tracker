class TripsController < ApplicationController
    skip_before_filter :check_authorization, only: [:show]

  def index
    @user = current_user
    @trips = Trip.all
  end
  
  def show
    @user = current_user
    @trip = Trip.find(params[:id])
    @photos = @trip.photos.sort {|a,b| a.date <=> b.date}
    session[:current_trip] = @trip.id
  end

  def edit
    @trip = current_user.trips.find_by_id(params[:id])
    if @trip
      session[:current_trip] = @trip.id
    else
      flash[:error] = "You don't have permissions to edit that trip"
      redirect_to root_path
    end
  end

  def destroy
    trip = current_user.trips.find_by_id(params[:id])
    trip.destroy if trip
    redirect_to user_path(current_user)
  end

  def create
    @user = current_user
    new_trip = current_user.trips.create(params[:trip])
    session[:current_trip] = new_trip.id
    redirect_to edit_trip_path(new_trip)
  end

  def new
    @trip = Trip.new
  end
 
 def update
  
  if params["trip_id"]
    @trip = Trip.find(params["trip_id"].to_i)
    session[:current_trip] = @trip.id
  else
    @trip = Trip.find(session[:current_trip])
    session[:current_trip] = @trip.id
  end

  if params['trip']['start']
    @trip.start = params['trip']['start']
    @trip.end = params['trip']['end']
    @trip.name = params['trip']['name']
    @trip.save! 
  end
  @trip.photos.each do |photo|
    if photo.date > @trip.end.to_i || photo.date < @trip.start.to_i
      photo.destroy
    end
  end
  redirect_to edit_trip_path
 end

def connect
    if session[:user_id]
      redirect_to Instagram.authorize_url(:redirect_uri => 'http://localhost:3000/instagram/callback')
    else
      redirect_to root_path
    end
  end

  def callback
    response = Instagram.get_access_token(params[:code], :redirect_uri => 'http://localhost:3000/instagram/callback')
    session[:access_token] = response.access_token
    @trip = Trip.find(session[:current_trip])
    client = Instagram.client(:access_token => session[:access_token])
    file = open("https://api.instagram.com/v1/users/#{client.user.id}/media/recent/?access_token=#{session[:access_token]}&min_timestamp=#{@trip.start.to_i-86400}&max_timestamp=#{@trip.end.to_i+86400}")
    data = file.read
    json_object = JSON.parse(data)
    json_object["data"].each do |photo|
      temp_photo = @trip.photos.find_or_initialize_by_url(caption: photo["caption"]["text"],
        date: photo["created_time"].to_i,
        url: photo['images']['standard_resolution']['url'],
        trip_id: @trip.id)
        temp_photo.update_attributes(lat: photo["location"]["latitude"],
          long: photo["location"]["longitude"]) if photo["location"]
        temp_photo.save!
    end
    session[:current_trip] = nil
    redirect_to edit_trip_path(@trip)
  end
  
  def load_trip
    @trip = Trip.find(params[:id] || params[:trip_id] || session[:current_trip])
    session[:current_trip_id] = @trip.id
  end

end
