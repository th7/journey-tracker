class SessionsController < ApplicationController

  skip_before_filter :check_authorization, :only => [:create,:destroy,:channel]
  def create
    user = User.create_from_fb_response(params['authResponse'])
    session[:user_id] = user.id
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end

  def destroy
    session.clear
    redirect_to root_url
  end

  def channel
    render 'channel'
  end

end
