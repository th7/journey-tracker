class MainController < ApplicationController

  def index
    if session[:access_token]
      @client = Instagram.client(:access_token => session[:access_token])
      @user = @client.user
      p "----------------"
      p @client.user_recent_media
    end
  end
end
