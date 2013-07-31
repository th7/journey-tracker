require 'spec_helper'

describe MainController do
  describe '#index' do
    it 'simply exists, at peace with the universe' do
      get :index
      expect('zen').to be_true
    end
  end
end