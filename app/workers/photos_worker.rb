class PhotosWorker 
  include Sidekiq::Worker

  def perform(params)

    user = User.find(params["user_id"].to_i)
    rest = Koala::Facebook::API.new(user.oauth_token)
    trip = Trip.find(params["trip_id"])
    fb_photos = []
    albums = rest.fql_query("SELECT name, aid, created, backdated_time FROM album WHERE (owner = #{user.uid} AND (created > #{trip.start.to_i} ) AND (created < #{trip.end.to_i}  ))")
    album_ids = []
    albums.each do |album|
      album_ids << album["aid"]
    end
    album_ids.each do |album_id|
      fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE (owner = #{user.uid} AND aid = #{album_id} AND created > #{trip.start.to_i}) AND (created < #{trip.end.to_i} )")
      fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE owner = #{user.uid} AND aid = #{album_id} AND (created > #{trip.start.to_i} OR backdated_time > #{trip.start.to_i} ) AND (created < #{trip.end.to_i} OR backdated_time < #{trip.end.to_i} )")
    end
    fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE (pid IN (SELECT pid FROM photo_tag WHERE subject=me()) AND (created > #{trip.start.to_i}) AND (created < #{trip.end.to_i}))")
    fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE (owner = me() AND (created > #{trip.start.to_i} ) AND (created < #{trip.end.to_i} ))")
    p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

    fb_photos.each do |set|
      set.each do |photo|
        if photo["backdated_time"]
          photo_date = photo["backdated_time"]
        else
          photo_date = photo["created"]
        end
        
        begin
          if photo["place_id"]
            place_response = rest.fql_query("SELECT latitude, longitude FROM place WHERE page_id = #{photo["place_id"]}")
            place_lat = place_response[0]["latitude"]
            place_long = place_response[0]["longitude"]
          end
        rescue NoMethodError => e
          p e
        end

        temp_photo = trip.photos.find_or_initialize_by_url(date: photo_date, url:photo["src_big"])
        temp_photo.update_attributes(lat: place_lat, long: place_long) if place_lat
        temp_photo.update_attributes(caption: photo["caption"]) if photo["caption"]
        temp_photo.save!
      end
    end
  end
end
