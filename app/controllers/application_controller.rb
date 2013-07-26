class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_authorization


  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def check_authorization
    unless current_user
      redirect_to root_path
    end
  end

end
