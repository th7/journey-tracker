class SessionsController < ApplicationController
require 'open-uri'

  skip_before_filter :check_authorization, :only => [:create,:destroy]
  def create
    user = User.from_omniauth(env["omniauth.auth"])

    session[:user_id] = user.id
    redirect_to root_url
  end

  def destroy
    session[:user_id] = nil
    session[:current_trip] = nil
    redirect_to root_url
  end

  def fetch_photos

    #add an oauth check/test to see if it's still valid
    p "===+===== STARTED FB FETCH =========="


    user = current_user
    rest = Koala::Facebook::API.new(user.oauth_token)
    trip = Trip.find(session[:current_trip])


    p user.oauth_token
    p rest

    # FQL QUERY FOR EVERYTHING:
    # fql_query("SELECT pid, src_big, src_big_height, src_big_width, caption, place_id, backdated_time, created FROM photo WHERE (pid IN (SELECT pid FROM photo_tag WHERE subject=me()) AND (created > 1370006043 OR backdated_time > 1370006043) AND (created < 1370006671 OR backdated_time < 1370006671)) OR (owner = me() AND (created > 1370006043 OR backdated_time > 1370006043) AND (created < 1370006671 OR backdated_time < 1370006671))")
    
    # KOALA SIMPLE QUERY
    # fb_response = rest.fql_query("SELECT name FROM user WHERE uid = me() ")
    
    # KOALA MULTI QUERY
    # fb_response = rest.fql_multiquery(
    #  :query1 => "select first_name from user where uid = 2905623",
    #  :query2 => "select first_name from user where uid = 2901279"
    # )

    # DIRECT URL QUERY
    # fql_query_url = "https://graph.facebook.com/fql?q=SELECT+pid,+src_big,+src_big_height,+src_big_width,+caption,+place_id,+backdated_time,+created+FROM+photo+WHERE+(pid+IN+(SELECT+pid+FROM+photo_tag+WHERE+subject=me())+AND+(created+>+1370006043+OR+backdated_time+>+1370006043)+AND+(created+<+1370006671+OR+backdated_time+<+1370006671))+OR+(owner+=+me()+AND+(created+>+1370006043+OR+backdated_time+>+1370006043)+AND+(created+<+1370006671+OR+backdated_time+<+1370006671))&access_token=#{user.oauth_token}"

    fql_query_url = open("https://graph.facebook.com/fql?q=SELECT+pid,+backdated_time,+created+FROM+photo+WHERE+owner+=+me()&access_token=#{user.oauth_token}")

    data = fql_query_url.readlines

    
    p "===+===== FB URL =========="
    p fql_query_url

    p "===+===== FB =========="
    p data
  
    # json_object["data"].each do |photo|
    #   temp_photo = @trip.photos.find_or_initialize_by_url(caption: photo["caption"]["text"], date: photo["created_time"].to_i, url:photo["images"]["standard_resolution"]["url"])
    #   temp_photo.update_attributes(lat: photo["location"]["latitude"], long: photo["location"]["longitude"]) if photo["location"]
    #   temp_photo.save!
    # end

    session[:current_trip] = nil

    redirect_to trip_path(trip)
  end

end
