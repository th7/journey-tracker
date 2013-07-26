require 'spec_helper'

describe SessionsController do
  describe '#create' do
    it 'redirects to root_url' do
      response.should redirect_to(root_url)
    end
  end
end
