class TripFacebookSessionController < ApplicationController
  require 'open-uri'
  def fetch_photos
    params["user_id"] = current_user.id
    p '!!!!!!!!!!!!!!!!'
    params["trip_id"] = session[:current_trip]
    # user = current_user
    # rest = Koala::Facebook::API.new(user.oauth_token)
    # trip = Trip.find(session[:current_trip])
    # fb_photos = []
    # albums = rest.fql_query("SELECT name, aid, created, backdated_time FROM album WHERE (owner = #{user.uid} AND (created > #{trip.start.to_i} ) AND (created < #{trip.end.to_i}  ))")
    # album_ids = []
    # albums.each do |album|
    #   album_ids << album["aid"]
    # end
    # album_ids.each do |album_id|
    #   fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE (owner = #{user.uid} AND aid = #{album_id} AND created > #{trip.start.to_i}) AND (created < #{trip.end.to_i} )")
    #   photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE owner = #{user.uid} AND aid = #{album_id} AND (created > #{trip.start.to_i} OR backdated_time > #{trip.start.to_i} ) AND (created < #{trip.end.to_i} OR backdated_time < #{trip.end.to_i} )")
    # end
    # fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE (pid IN (SELECT pid FROM photo_tag WHERE subject=me()) AND (created > #{trip.start.to_i}) AND (created < #{trip.end.to_i}))")
    # fb_photos << rest.fql_query("SELECT pid, src_big, caption, place_id, backdated_time, created FROM photo WHERE (owner = me() AND (created > #{trip.start.to_i} ) AND (created < #{trip.end.to_i} ))")
    # fb_photo_ids = []
    # fb_photos.each do |set|
    #   set.each do |photo|
    #     fb_photo_ids << trip.photos.find_or_initialize_by_url(url:photo["src_big"]).id
    #     end
    #   
    # end
    PhotosWorker.perform_async(params)
    redirect_to edit_trip_path(params["trip_id"])
  end
end
