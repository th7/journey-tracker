class PhotosController < ApplicationController
require 'open-uri'
	def index
		@user = current_user
		@trip = Trip.find(session[:current_trip])
		@photos = @trip.photos
	end

	def create
		@trip = Trip.find(session[:current_trip])
		p "======= PHOTO PARAMS ==============="
		p params["url"]
		p params["filetype"]

		if ["image/jpeg","image/jpg"].include?(params["filetype"])
			new_photo = @trip.photos.find_or_initialize_by_url(url: params["url"])
			# get_exif_data(new_photo)
			new_photo.save
		end

		redirect_to photos_path
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

	def test
		p "================== OH MY GOD =============="
		p params
		p "==========================================="
	end

	def testview
		
	end

end


