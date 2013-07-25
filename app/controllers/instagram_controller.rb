class InstagramController < ApplicationController
  def connect
  redirect_to Instagram.authorize_url(:redirect_uri => 'http://localhost:3000/instagram/callback')
  end

  def callback
    response = Instagram.get_access_token(params[:code], :redirect_uri => 'http://localhost:3000/instagram/callback')
    session[:access_token] = response.access_token
    redirect_to root_path
  end

end
