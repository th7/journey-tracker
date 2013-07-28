class Photo < ActiveRecord::Base
  attr_accessible :caption, :url, :lat, :long, :date, :color1, :color2, :color3, :color4
  belongs_to :trip

  before_save :get_photo_colors

  validates_presence_of :url
  validates_uniqueness_of :url


  def get_photo_colors
    Miro.options[:color_count] = 4
    colors = Miro::DominantColors.new(self.url).to_hex
    self.color1 = colors[0]
    self.color2 = colors[1]
    self.color3 = colors[2]
    self.color4 = colors[3]
  end


require 'uri'

  def get_exif_data(photo)
  	# image = MiniMagick::Image.open(photo.url)
  	# image["EXIF:BitsPerSample"]
  	# EXIFR::JPEG.new(image).gps.latitude
		# EXIFR::JPEG.new(image).gps.longitude
		# EXIFR::JPEG.new(image).date_time

  end

end
