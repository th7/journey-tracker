require 'spec_helper'

describe SessionsController do
  # describe '#create' do
    # it 'redirects to root_url' do
    	# pending 'NOT SURE HOW TO TEST OMNIAUTH'
      # response.should redirect_to(root_url)
    # end
  # end

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

  describe '#fetch_photos' do
  	
  end

end
