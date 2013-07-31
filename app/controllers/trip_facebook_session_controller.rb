class TripFacebookSessionController < ApplicationController
  require 'open-uri'
  def fetch_photos

      user = current_user
      p "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      p user
      rest = Koala::Facebook::API.new(user.oauth_token)
      trip = Trip.find(session[:current_trip])
      p trip.start
      p trip.end
      p trip
      fb_photos = []

      # file = open("https://graph.facebook.com/#{user.uid}?fields=albums.limit(5)&access_token=#{user.oauth_token}")
      # data = file.read
      # json_stuff = JSON.parse(data)
      p "_______________________________________________"
      p trip.start.to_i
      p trip.end.to_i
      # albums = rest.fql_query("SELECT name, aid, created, backdated_time FROM album WHERE (owner = #{user.uid} AND (created > #{trip.start.to_i} OR backdated_time > #{trip.start.to_i}) AND (created < #{trip.end.to_i} OR backdated_time < #{trip.end.to_i} ))")
      albums = rest.fql_query("SELECT name, aid, created, backdated_time FROM album WHERE (owner = #{user.uid} AND (created > #{trip.start.to_i} ) AND (created < #{trip.end.to_i}  ))")
      album_ids = []
      albums.each do |album|
        album_ids << album["aid"]
      end
      
      
      album_ids.each do |album_id|
     fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE (owner = #{user.uid} AND aid = #{album_id} AND created > #{trip.start.to_i}) AND (created < #{trip.end.to_i} )")
     
        # fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE owner = #{user.uid} AND aid = #{album_id} AND (created > #{trip.start.to_i} OR backdated_time > #{trip.start.to_i} ) AND (created < #{trip.end.to_i} OR backdated_time < #{trip.end.to_i} )")
      end

        p "!!!!!!!!!!!!!!!!"+Time.now.to_s
      fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE (pid IN (SELECT pid FROM photo_tag WHERE subject=me()) AND (created > #{trip.start.to_i}) AND (created < #{trip.end.to_i}))")
      fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE (owner = me() AND (created > #{trip.start.to_i} ) AND (created < #{trip.end.to_i} ))")
      # fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE (pid IN (SELECT pid FROM photo_tag WHERE subject=me()) AND (created > #{trip.start.to_i} OR backdated_time > #{trip.start.to_i}) AND (created < #{trip.end.to_i} OR backdated_time < #{trip.end.to_i}))")
      # fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE (owner = me() AND (created > #{trip.start.to_i} OR backdated_time > #{trip.start.to_i}) AND (created < #{trip.end.to_i} OR backdated_time < #{trip.end.to_i}))")

  
      
    p "!!!!!!!!!!!!!!!!!!!!"+Time.now.to_s
      fb_photos.each do |set|
        set.each do |photo|

          if photo["backdated_time"]
            photo_date = photo["backdated_time"]
          else
            photo_date = photo["created"]
          end

          if photo["place_id"]
            place_response = rest.fql_query("SELECT latitude, longitude FROM place WHERE page_id = #{photo["place_id"]}")
            place_lat = place_response[0]["latitude"]
            place_long = place_response[0]["longitude"]
          end

          temp_photo = trip.photos.find_or_initialize_by_url(caption: photo["caption"], date: photo_date, url:photo["src_big"])
          temp_photo.update_attributes(lat: place_lat, long: place_long) if photo["place_id"]
          temp_photo.save!

        end
      end

p "!!!!!!!!!!!!!!!!!!!!"+Time.now.to_s
      # session[:current_trip] = nil
      redirect_to edit_trip_path(trip)
    end

end
