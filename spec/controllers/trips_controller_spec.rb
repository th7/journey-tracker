require 'spec_helper'


describe TripsController do
  before(:all) do
    User.delete_all
    Trip.delete_all
    Photo.delete_all

    @test_user = User.create(name: 'test', uid: 1, oauth_token: 1, provider: 1)

    @test_trip_params = {name: "STUFF", start: Time.now, end: Time.now}
    @test_trip = @test_user.trips.create(@test_trip_params)

    @test_photos = []
    @test_photos << Photo.new(url: '1', date: Time.now)
    @test_photos << Photo.new(url: '2', date: Time.now - 100)
    @test_photos.each {|p| p.stub(:get_photo_colors)}
    @test_trip.photos << @test_photos
  end

  describe '#index' do
    context 'user is logged in' do
      before(:each) do
        session[:user_id] = @test_user.id
      end

      it 'shows all trips' do
        trips = double(:trips)
        Trip.stub(:all).and_return trips
        get :index
        assigns(:trips).should == trips
      end
    end

    context 'user is not logged in' do
      before(:each) do
        session.clear
      end
      
      it 'doesnt show all trips' do
        trips = double(:trips)
        Trip.stub(:all).and_return trips
        get :index
        assigns(:trips).should == nil
      end
    end
  end

  describe '#show' do
    context 'user is logged in' do
      before(:each) do
        session[:user_id] = @test_user.id
        get :show, id: @test_trip.id
      end

      it 'assigns a trip' do
        assigns(:trip).should == @test_trip
      end

      it 'assigns a date sorted list of the trips photos' do
        expect(assigns(:photos)).to eq @test_photos.sort { |a,b| a.date <=> b.date }
      end
    end

    context 'user is not logged in' do
      before(:each) do
        session.clear
        get :show, id: @test_trip.id
      end
      
      it 'assigns a trip' do
        assigns(:trip).should == @test_trip
      end

      it 'assigns a date sorted list of the trips photos' do
        expect(assigns(:photos)).to eq @test_photos.sort { |a,b| a.date <=> b.date }
      end
    end
  end

  describe '#create' do
    context 'user is logged in' do
      before(:each) do
        session[:user_id] = @test_user.id
      end

      it 'creates a trip' do
        expect{post :create, trip: @test_trip_params}.to change{Trip.count}.by(1)
      end
    end

    context 'user is not logged in' do
      before(:each) do
        session.clear
      end

      it 'doesnt create a trip' do
        expect{post :create, trip: @test_trip_params}.not_to change{Trip.count}
      end
    end
  end
end
