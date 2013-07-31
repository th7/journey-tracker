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
    trip_id = params[:trip_id] || session[:current_trip]
    trip = current_user.trips.find_by_id(trip_id)
    # @trip = Trip.find(session[:current_trip])
		# {"url"=>"http://i.imgur.com/5drf5AG.jpg", "date"=>"2013:05:04 09:56:14", "lat"=>"N", "lon"=>"E", "action"=>"create", "controller"=>"photos"}
		# {"url"=>"http://i.imgur.com/cabjMk2.jpg", "date"=>"2013:05:04 09:56:14", "lat"=>["21", "1.77", "0"], "lon"=>["105", "50.91", "0"], "action"=>"create", "controller"=>"photos"}
		# {"url"=>"http://i.imgur.com/fHHpwBj.jpg", "date"=>"2013:05:04 09:56:14", "lat"=>["21", "1.77", "0"], "lon"=>["105", "50.91", "0"], "latRef"=>"N", "lonRef"=>"E", "action"=>"create", "controller"=>"photos"}
		# DateTime.strptime("2013:05:04 09:56:14","%Y:%m:%d %T").to_i
		url = params[:photo][:url].gsub!(/(\.)([^\.]*)\z/,'h\1\2')
		new_photo = trip.photos.find_or_initialize_by_url(url: url)
    new_photo.update_attributes(params[:photo])

		redirect_to '/' #junk placeholder pending merge -- delete me

	end

	def show
		@photo = Photo.find(params[:id])
	end

	def update
    trip = current_user.trips.find_by_id(params[:trip_id])
    photo = trip.photos.find_by_id(params[:id]) if trip
    photo.update_attributes(params[:photo])

		# p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
		# p params['photo_date'].to_datetime
		# @temp_photo = Photo.find(params['photo_id'])
		# @temp_photo.update_attributes(caption: params["photo_caption"],
		# 																								lat: params["photo_lat"],
		# 																								long: params["photo_long"],
		# 																								date: params["photo_date"].to_datetime.to_i)
    
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
    trip = current_user.trips.find_by_id(params[:trip_id])
    Photo.find(params['id']).destroy
    @trip = Trip.find(session[:current_trip])    
    redirect_to edit_trip_path(@trip.id)
  end

end


