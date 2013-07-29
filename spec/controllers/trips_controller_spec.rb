require 'spec_helper'

describe TripsController do
  describe '#index' do
    it 'shows all trips' do
      trips = double(:trips)
      Trip.stub(:all).and_return trips
      get :index
      assigns(:trips).should == trips
    end
  end
  describe '#create' do
    # let(:user){double(:user)}
    # user.stub(:trips).and_return trips
    it 'creates a trip' do
      # trip = @user.trips.create()
      options = {name: "STUFF"}
      post :create, {question: options}
      # controller.stub(:current_user).and_return user
    end
  end
end
