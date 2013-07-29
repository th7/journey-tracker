class MainController < ApplicationController
  skip_before_filter :check_authorization, only: [:index]


  def index
    @user = current_user
  end
end
