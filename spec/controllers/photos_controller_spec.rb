require 'spec_helper'

describe PhotosController do
  before(:all) do
    User.delete_all
    Trip.delete_all

    @test_user = User.create(name: 'test', uid: 1, oauth_token: 1, provider: 1)

    @imposter_user = User.create(name: 'imposter', uid: 2, oauth_token: 2, provider: 1)

    @test_trip_params = {name: "STUFF", start: Time.now, end: Time.now}
    @test_trip = @test_user.trips.create(@test_trip_params)

  end

  before(:each) do
    Photo.delete_all
    @test_photos = []
    @test_photos << Photo.new(url: '1.jpg', date: Time.now)
    @test_photos << Photo.new(url: '2.png', date: Time.now - 100)
    @test_photos.each do |p| 
      # p.stub(:get_photo_colors)
    end
    @test_photo_params = {url: '3.jpg'}
    @test_trip.photos << @test_photos
  end
  
  describe '#index' do
    pending 'likely do be deleted'
  end
  
  describe '#new' do
    pending 'likely do be deleted'
  end
  
  describe '#create' do
    context 'when user is logged in' do
      before(:each) do
        session[:user_id] = @test_user.id
      end

      it 'creates a photo using params' do
        expect{post :create, trip_id: @test_trip.id, photo: @test_photo_params}.to change{Photo.count}.by(1)
      end

      it 'creates a photo using session trip' do
        session[:current_trip] = @test_trip.id
        expect{post :create, photo: @test_photo_params}.to change{Photo.count}.by(1)
      end

      it 'creates a photo eith exif_date' do
        expect{post :create, trip_id: @test_trip.id, photo: {exif_date: '2013:05:04 09:56:14', url: 'atest.jpg'}}.to change{Photo.count}.by(1)
      end
    end

    context 'when user is not logged in' do
      before(:each) do
        session.clear
      end

      it 'doesnt create a photo' do
        expect{post :create, trip_id: @test_trip.id, photo: @test_photo_params}.not_to change{Trip.count}
      end
    end
  end
  
  describe '#show' do
    pending 'likely do be deleted'
  end
  
  describe '#update' do
    pending
  end
  
  describe '#destroy' do
    pending
  end
end