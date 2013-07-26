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

    redirect_to trips_path
  end

end
