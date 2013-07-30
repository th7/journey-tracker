class TripInstagramSessionController < ApplicationController
  def new
    if session[:user_id]
      # don't hardcode the callback url:
      instagram_callback_url = "instagram/callback"
      redirect_to Instagram.authorize_url(:redirect_uri => root_url+instagram_callback_url)
    else
      redirect_to root_path
    end
  end

  def create
    response = Instagram.get_access_token(params[:code], :redirect_uri => 'http://localhost:3000/instagram/callback')
    session[:access_token] = response.access_token
    @trip = Trip.find(session[:current_trip])
    client = Instagram.client(:access_token => session[:access_token])
    file = open("https://api.instagram.com/v1/users/#{client.user.id}/media/recent/?access_token=#{session[:access_token]}&min_timestamp=#{@trip.start.to_i-86400}&max_timestamp=#{@trip.end.to_i+86400}")
    data = file.read
    json_object = JSON.parse(data)
    json_object["data"].each do |photo|
      p "-------PHOTO CAPTION---------"
     p photo['caption']
      temp_photo = @trip.photos.find_or_initialize_by_url(
        date: photo["created_time"].to_i,
        url: photo['images']['standard_resolution']['url'])
        temp_photo.update_attributes(lat: photo["location"]["latitude"],
          long: photo["location"]["longitude"]) if photo["location"]
        temp_photo.update_attributes(caption: photo["caption"]["text"]) if photo["caption"]
        temp_photo.save!
    end
    session[:current_trip] = nil
    redirect_to edit_trip_path(@trip)
  end
end
