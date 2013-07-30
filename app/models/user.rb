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

end
