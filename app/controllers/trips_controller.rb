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
    # render layout: false
  end

  def edit
    @user = current_user
    @trip = Trip.find(params[:id])
    session[:current_trip] = @trip.id
    @trip_user = @trip.user
    @photos =Trip.json_storage(@trip.id)["data"] if Trip.json_storage(@trip.id)
    @chosen_photos = @trip.photos if @trip.photos
    
   
  end

  def destroy
    Trip.find(params["id"]).destroy
    redirect_to user_path(current_user)
  end

  def create
    @user = current_user
    new_trip = @user.trips.create(params[:trip])
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
    @trip.save!
    redirect_to "/instagram/connect"
  else
    
  if params["trip"]["photo_ids"]
  params["trip"]["photo_ids"].each do |photo_id|
    temp_photo = @trip.photos.find_or_initialize_by_url(caption: params["photos"][photo_id]["caption"], date: params["photos"][photo_id]["date"].to_i, url:params["photos"][photo_id]['url'], trip_id: @trip.id)
      temp_photo.update_attributes(lat: params["photos"][photo_id]["location"]["latitude"], long: params["photos"][photo_id]["location"]["longitude"]) if params["photos"][photo_id]["location"]
      temp_photo.save!
  end
end
  redirect_to edit_trip_path
end
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
    Trip.json_storage(@trip.id, json_object)
    session[:current_trip] = nil
    redirect_to edit_trip_path(@trip)
  end


end
