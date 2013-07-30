class PhotosController < ApplicationController
	def index
		@user = current_user
		@trip = Trip.find(session[:current_trip])
		@photos = @trip.photos
	end

	def new
		# @trip = Trip.find(session[:current_trip])
	end

	def create
		@trip = Trip.find(session[:current_trip])
		p "======= PHOTO PARAMS ==============="
		p params

		new_photo = @trip.photos.find_or_initialize_by_url(url: params["url"].gsub!(/(\.)([^\.]*)\z/,'h\1\2'))
		new_photo.save
		new_photo.update_attributes(date: DateTime.strptime(params["date"],"%Y:%m:%d %T").to_i) if params["date"]

		if params["lon"]
			new_photo.set_gps_as_decimal(params["lat"],params["latRef"])
			new_photo.set_gps_as_decimal(params["lon"],params["lonRef"])
		end

		render :nothing => true, :status => 200, :content_type => 'text/html'

	end

	def show
		@photo = Photo.find(params[:id])
	end

	def update
		p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
		p params['photo_date'].to_datetime
		@temp_photo = Photo.find(params['photo_id'])
		@temp_photo.update_attributes(caption: params["photo_caption"],
																										lat: params["photo_lat"],
																										long: params["photo_long"],
																										date: params["photo_date"].to_datetime.to_i)
    
    if request.xhr?
    	@trip = @temp_photo.trip
    	render partial: "trips/photo_details", :locals => {:photo => @temp_photo}
    end

    # respond_to do |format|
    

    # 	# format.json do
    #  #    @errors = []
    #  #    if @temp_photo.save!
    #  #      render :json => {:caption => @temp_photo.caption,
    #  #                       :lat => @temp_photo.lat,
    #  #                       :long => @temp_photo.long,
    #  #                       :date => Time.at(@temp_photo.date),
    #  #                       :photo_id => @temp_photo.id,
    #  #                       :trip_id => @temp_photo.trip.id}
    #  #    else
    #  #    	render :json => {:error => "Unable to save post"}
    #  #    end
    #  #  end
    # end
	end
  
  def destroy
    Photo.find(params['id']).destroy
    @trip = Trip.find(session[:current_trip])    
    redirect_to edit_trip_path(@trip.id)
  end

end


