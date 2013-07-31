require 'spec_helper'

describe PhotosController do
  before(:all) do
    User.delete_all
    Trip.delete_all

    @test_user = User.create(name: 'test', uid: 1, oauth_token: 1, provider: 1)

    @imposter_user = User.create(name: 'imposter', uid: 2, oauth_token: 2, provider: 1)

    @test_trip_params = {name: "STUFF", start: Time.now, end: Time.now}
    @test_trip = @test_user.trips.create(@test_trip_params)
    Photo.skip_callback(:create, :after, :get_photo_colors)
  end

  after(:all) do
    Photo.set_callback(:create, :after, :get_photo_colors)
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
    before(:each) do
      @to_update = @test_trip.photos.create(@test_photo_params)
      @new_url = 'thisisanewurl.jpg'
    end

    context 'when user is logged in' do
      before(:each) do
        session[:user_id] = @test_user.id
        post :update, photo: {id: @to_update.id, trip_id: @test_trip.id, url: @new_url}
      end

      it 'updates the correct photo' do
        expect(@test_trip.photos.find_by_id(@to_update.id).url).to eq @new_url
      end
    end

    context 'when imposter user is logged in' do
      before(:each) do
        session.clear
        session[:user_id] = @imposter_user.id
        post :update, photo: {id: @to_update.id, trip_id: @test_trip.id, url: @new_url}
      end

      it 'does not update the photo' do
        expect(@test_trip.photos.find_by_id(@to_update.id).url).to_not eq @new_url
      end
    end

    context 'when user is not logged in' do
      before(:each) do
        session.clear
        post :update, photo: {id: @to_update.id, trip_id: @test_trip.id, url: @new_url}
      end

      it 'does not update the photo' do
        expect(@test_trip.photos.find_by_id(@to_update.id).url).to_not eq @new_url
      end
    end
  end
  
  describe '#destroy' do
    before(:each) do
      @to_delete = @test_trip.photos.create(@test_photo_params)
    end

    context 'when user is logged in' do
      before(:each) do
        session[:user_id] = @test_user.id
        post :destroy, id: @to_delete.id
      end

      it 'deletes the correct photo' do
        expect(@test_trip.photos.find_by_id(@to_delete.id)).to eq nil
      end
    end

    context 'when imposter user is logged in' do
      before(:each) do
        session.clear
        session[:user_id] = @imposter_user.id
        post :destroy, id: @to_delete.id
      end

      it 'does not delete the photo' do
        expect(@test_trip.photos.find_by_id(@to_delete.id)).to eq @to_delete
      end
    end

    context 'when user is not logged in' do
      before(:each) do
        session.clear
        post :destroy, id: @to_delete.id
      end

      it 'does not delete the photo' do
        expect(@test_trip.photos.find_by_id(@to_delete.id)).to eq @to_delete
      end
    end
  end
end