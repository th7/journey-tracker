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


    Photo.skip_callback(:create, :after, :get_photo_colors)
    @test_photos = []
    @test_photos << Photo.new(url: '1', date: Time.now)
    @test_photos << Photo.new(url: '2', date: Time.now - 100)
    @test_trip.photos << @test_photos
  end

  after(:all) do
    Photo.set_callback(:create, :after, :get_photo_colors)
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

      it 'assigns @trips to all this users trips' do
        trips = @test_user.trips.reload
        # Trip.stub(:all).and_return trips
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
        get :show, id: @test_trip.slug
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
        get :show, id: @test_trip.slug
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
        get :edit, id: @test_trip.slug
      end

      it 'assigns the correct trip' do
        expect(assigns(:trip)).to eq @test_trip
      end
    end

    context 'when imposter user is logged in' do
      before(:each) do
        session.clear
        session[:user_id] = @imposter_user.id
        get :edit, id: @test_trip.slug
      end

      it 'does not assign the trip' do
        expect(assigns(:trip)).to eq nil
      end
    end

    context 'when user is not logged in' do
      before(:each) do
        session.clear
        get :edit, id: @test_trip.slug
      end

      it 'does not assign the trip' do
        expect(assigns(:trip)).to eq nil
      end
    end
  end

  describe '#destroy' do
    before(:each) do
      @to_delete = @test_user.trips.create(@test_trip_params)
    end

    context 'when user is logged in' do
      before(:each) do
        session[:user_id] = @test_user.id
        post :destroy, id: @to_delete.slug
      end

      it 'deletes the correct trip' do
        expect(@test_user.trips.find_by_id(@to_delete.id)).to eq nil
      end
    end

    context 'when imposter user is logged in' do
      before(:each) do
        session.clear
        session[:user_id] = @imposter_user.id
        post :destroy, id: @to_delete.slug
      end

      it 'does not delete the trip' do
        expect(@test_user.trips.find_by_id(@to_delete.id)).to eq @to_delete
      end
    end

    context 'when user is not logged in' do
      before(:each) do
        session.clear
        post :destroy, id: @to_delete.slug
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
        expect(assigns(:trip)).to be_kind_of(Trip)
      end
    end
  end

  describe '#update' do
    before(:each) do
      @to_update = @test_user.trips.create(@test_trip_params)
      @new_name = 'this is a new name'
    end

    context 'when user is logged in' do
      before(:each) do
        session[:user_id] = @test_user.id
        post :update, id: @to_update.slug, trip: {name: @new_name}
      end

      it 'updates the correct trip' do
        expect(@test_user.trips.find_by_id(@to_update.id).name).to eq @new_name
      end
    end

    context 'when imposter user is logged in' do
      before(:each) do
        session.clear
        session[:user_id] = @imposter_user.id
        post :update, id: @to_update.slug, trip: {name: @new_name}
      end

      it 'does not update the trip' do
        expect(@test_user.trips.find_by_id(@to_update.id).name).to_not eq @new_name
      end
    end

    context 'when user is not logged in' do
      before(:each) do
        session.clear
        post :update, id: @to_update.slug, trip: {name: @new_name}
      end

      it 'does not update the trip' do
        expect(@test_user.trips.find_by_id(@to_update.id).name).to_not eq @new_name
      end
    end
  end
end
