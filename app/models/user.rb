class User < ActiveRecord::Base
  attr_accessible :name, :uid, :oauth_token, :provider
  has_many :trips
  has_many :photos, through: :trips
  validates_presence_of :name, :uid, :oauth_token, :provider
  validates_uniqueness_of :uid, :oauth_token

  def facebook
    @facebook ||= Koala::Facebook::API.new(oauth_token)
  end

  def self.from_omniauth(auth)
      where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.name = auth.info.name
        user.oauth_token = auth.credentials.token
        user.oauth_expires_at = Time.at(auth.credentials.expires_at)
        user.save!
      end

  end

  def self.create_from_fb_response(response)
    token = response['accessToken']
    result = open("https://graph.facebook.com/me?fields=name&oauth_token=#{token}").read

    params = {
      provider: 'facebook',
      uid: response['userID'],
      oauth_token: token,
      name: JSON.parse(result)['name']
    }
    user = User.find_or_initialize_by_uid(params[:uid])
    user.update_attributes(params)
    user
  end

end
