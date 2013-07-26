class InstagramController < ApplicationController
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
    client.user_recent_media.each do |photo|
      temp_photo = @trip.photos.find_or_initialize_by_url(caption: photo.caption.text, date: photo.caption.created_time.to_i, url:photo.images.standard_resolution.url)
      temp_photo.update_attributes(lat: photo.location.latitude, long: photo.location.longitude) if photo.location
      temp_photo.save!
    end

    session[:current_trip] = nil

    redirect_to trip_path(@trip)
  end

end
