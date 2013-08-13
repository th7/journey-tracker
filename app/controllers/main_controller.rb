class MainController < ApplicationController
  skip_before_filter :check_authorization, only: [:index]

  def index
  	if current_user
      if current_user.trips.empty?
  	  	redirect_to new_trip_path
      else
        redirect_to trips_path
      end
	  end
  end
end
