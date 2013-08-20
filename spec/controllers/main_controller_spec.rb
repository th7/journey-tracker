require 'spec_helper'

describe MainController do
  context 'user is not logged in' do
    before do
      session.clear
    end

    describe '#index' do
      it 'does not redirect' do
        get :index
        expect(response.code).to eq '200'
      end
    end
  end
  context 'user is logged in' do
    before do
      User.delete_all
      @user = User.new(:name => 'test', :uid => 1, :oauth_token => 1, :provider => 1)
      @user.save!
      session[:user_id] = @user.id
    end

    context 'user has no trips' do
      before do
        @user.trips.delete_all
      end

      describe '#index' do
        it 'redirects to new_trip_path' do
          get :index
          expect(response).to redirect_to new_trip_path
        end
      end
    end

    context 'user has trips' do
      before do
        @trip = @user.trips.new(:name => 'test trip', :start => Time.now, :end => Time.now)
        @trip.save!
      end

      describe '#index' do
        it 'redirects to trip_path' do
          get :index
          expect(response).to redirect_to trips_path
        end
      end

    end
  end
end
