class MainController < ApplicationController
  skip_before_filter :check_authorization, only: [:index]

  def index
  	redirect_to new_trip_path if current_user.trips
  end
end
