class TripFacebookSessionController < ApplicationController
  def fetch_photos

      user = current_user
      p "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      p user
      rest = Koala::Facebook::API.new(user.oauth_token)
      trip = Trip.find(session[:current_trip])
      fb_photos = []
    
      albums = rest.fql_query("SELECT name,aid FROM album WHERE (owner = 1243410027 AND (created >1365555661 OR backdated_time > 1365555661 ) ) AND (created > 1365555661 OR backdated_time > 1365555661) AND (created < 1367283661 OR backdated_time < 1367283661 )")

        p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      p albums
      fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE (pid IN (SELECT pid FROM photo_tag WHERE subject=me()) AND (created > #{trip.start.to_i} OR backdated_time > #{trip.start.to_i}) AND (created < #{trip.end.to_i} OR backdated_time < #{trip.end.to_i}))")
      fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE (owner = me() AND (created > #{trip.start.to_i} OR backdated_time > #{trip.start.to_i}) AND (created < #{trip.end.to_i} OR backdated_time < #{trip.end.to_i}))")

  # SELECT name,aid FROM album WHERE (owner = 1243410027 AND (created >1365555661 OR backdated_time > 1365555661 ) ) AND (created > 1365555661 OR backdated_time > 1365555661) AND (created < 1367283661 OR backdated_time < 1367283661 )
      

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


      session[:current_trip] = nil
      redirect_to edit_trip_path(trip)
    end

end
