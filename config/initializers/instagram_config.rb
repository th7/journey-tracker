INSTAGRAM_CALLBACK_URL = 'http://localhost:3000/instagram/callback'
Instagram.configure do |config|
  config.client_id = ENV['INSTAGRAM_ID']
  config.client_secret = ENV['INSTAGRAM_SECRET']
end
