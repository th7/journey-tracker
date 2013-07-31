class TripFacebookSessionController < ApplicationController
  require 'open-uri'
  def fetch_photos
    params["user_id"] = current_user.id
    params["trip_id"] = session[:current_trip]
    
    PhotosWorker.perform_async(params)
    redirect_to edit_trip_path(params["trip_id"])
  end
end
