class InstagramController < ApplicationController
require 'open-uri'

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
    p "======= Client ID ========"
    p "https://api.instagram.com/v1/users/#{client.user.id}/media/recent/?access_token=#{session[:access_token]}&min_timestamp=#{@trip.start.to_i-86400}&max_timestamp=#{@trip.end.to_i+86400}"
    p "======= Client ID ========"
    p client.user.id
    p "======= Access Token ========"
    p session[:access_token]
    data = file.read
    json_object = JSON.parse(data)
    p "======= JSON ========"
    p json_object

  
    json_object["data"].each do |photo|
      temp_photo = @trip.photos.find_or_initialize_by_url(caption: photo["caption"]["text"], date: photo["created_time"].to_i, url:photo["images"]["standard_resolution"]["url"])
      temp_photo.update_attributes(lat: photo["location"]["latitude"], long: photo["location"]["longitude"]) if photo["location"]
      temp_photo.save!
    end

    session[:current_trip] = nil

    redirect_to trip_path(@trip)
  end

end
