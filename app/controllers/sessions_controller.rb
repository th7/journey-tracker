class SessionsController < ApplicationController
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
end
