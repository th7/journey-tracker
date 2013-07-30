require 'spec_helper'


describe TripsController do
  before(:all) do
    User.delete_all
    Trip.delete_all
    Photo.delete_all

    @test_user = User.create(name: 'test', uid: 1, oauth_token: 1, provider: 1)

    @imposter_user = User.create(name: 'imposter', uid: 2, oauth_token: 2, provider: 1)

    @test_trip_params = {name: "STUFF", start: Time.now, end: Time.now}
    @test_trip = @test_user.trips.create(@test_trip_params)

    @test_photos = []
    @test_photos << Photo.new(url: '1', date: Time.now)
    @test_photos << Photo.new(url: '2', date: Time.now - 100)
    @test_photos.each {|p| p.stub(:get_photo_colors)}
    @test_trip.photos << @test_photos
  end

  before(:each) do
    session.clear
    @current_user = nil
  end

  describe '#index' do
    context 'when user is logged in' do
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

    context 'when user is not logged in' do
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
    context 'when user is logged in' do
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

    context 'when user is not logged in' do
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

  describe '#edit' do
    context 'when user is logged in' do
      before(:each) do
        session[:user_id] = @test_user.id
        get :edit, id: @test_trip.id
      end

      it 'assigns the correct trip' do
        expect(assigns(:trip)).to eq @test_trip
      end
    end

    context 'when imposter user is logged in' do
      before(:each) do
        session.clear
        session[:user_id] = @imposter_user.id
        get :edit, id: @test_trip.id
      end

      it 'does not assign the trip' do
        expect(assigns(:trip)).to eq nil
      end
    end

    context 'when user is not logged in' do
      before(:each) do
        session.clear
        get :edit, id: @test_trip.id
      end

      it 'does not assign the trip' do
        expect(assigns(:trip)).to eq nil
      end
    end
  end

  describe '#destroy' do
    before(:each) do
      @to_delete = @test_user.trips.create(@test_trip_params);
    end

    context 'when user is logged in' do
      before(:each) do
        session[:user_id] = @test_user.id
        post :destroy, id: @to_delete.id
      end

      it 'deletes the correct trip' do
        expect(@test_user.trips.find_by_id(@to_delete.id)).to eq nil
      end
    end

    context 'when imposter user is logged in' do
      before(:each) do
        session.clear
        session[:user_id] = @imposter_user.id
        post :destroy, id: @to_delete.id
      end

      it 'does not delete the trip' do
        expect(@test_user.trips.find_by_id(@to_delete.id)).to eq @to_delete
      end
    end

    context 'when user is not logged in' do
      before(:each) do
        session.clear
        post :destroy, id: @to_delete.id
      end

      it 'does not delete the trip' do
        expect(@test_user.trips.find_by_id(@to_delete.id)).to eq @to_delete
      end
    end
  end

  describe '#create' do
    context 'when user is logged in' do
      before(:each) do
        session[:user_id] = @test_user.id
      end

      it 'creates a trip' do
        expect{post :create, trip: @test_trip_params}.to change{Trip.count}.by(1)
      end
    end

    context 'when user is not logged in' do
      before(:each) do
        session.clear
      end

      it 'doesnt create a trip' do
        expect{post :create, trip: @test_trip_params}.not_to change{Trip.count}
      end
    end
  end

  describe '#new' do
    context 'when user is logged in' do
      before(:each) do
        session[:user_id] = @test_user.id
      end
      it 'assigns a new trip' do
        get :new
        expect(assigns(:trip)).to eq Trip.new
      end
    end
  end
end
