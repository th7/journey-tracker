class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_authorization


  private

  def current_user
    p @current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end
  # helper_method :current_user

  def check_authorization
    redirect_to root_path unless current_user
  end

end
