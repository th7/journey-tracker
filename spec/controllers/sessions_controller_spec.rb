require 'spec_helper'

describe SessionsController do
  describe '#create' do
    before do
      User.delete_all
      @user = User.new(:name => 'test', :uid => 1, :oauth_token => 1, :provider => 1)
      @user.save!
      allow(User).to receive(:create_from_fb_response) { @user }
    end

    it 'puts user id in the session' do
      post :create
      expect(session[:user_id]).to eq @user.id
    end

    it 'does not redirect' do
      post :create
      expect(response.code).to eq '200'
    end
  end

  describe '#destroy' do
    it 'removes sessions' do
    	session[:user_id] = 1
    	session[:current_trip] = 1
    	get :destroy
    	session[:user_id].should be_nil
    	session[:current_trip].should be_nil
    end

    it 'redirect back to root' do
    	get :destroy
    	response.should redirect_to root_url
    end
  end

  describe '#channel' do
    it 'does not redirect' do
      get :channel
      expect(response.code).to eq '200'
    end
  end
end
