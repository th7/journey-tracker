class MainController < ApplicationController

  def index
    if session[:access_token]
      @client = Instagram.client(:access_token => session[:access_token])
      @user = @client.user
      p "============================"
      p @client.user_recent_media[0].caption.created_time
      @client.user_recent_media.each do |photo|
        temp_photo = Photo.find_or_initialize_by_url(caption: photo.caption.text, date: photo.caption.created_time.to_i, url:photo.images.standard_resolution.url)
        temp_photo.update_attributes(lat: photo.location.latitude, long: photo.location.longitude) if photo.location
        temp_photo.save!
      end

      @photos = Photo.order("date ASC")

    end
  end
end
