class Photo < ActiveRecord::Base
  attr_accessible :caption, :url, :lat, :long, :date
  belongs_to :trip

  validates_presence_of :url
  validates_uniqueness_of :url

require 'uri'

  def get_exif_data(photo)
  	image = MiniMagick::Image.open(photo.url)
  	image["EXIF:BitsPerSample"]
  # 	EXIFR::JPEG.new(image).gps.latitude
		# EXIFR::JPEG.new(image).gps.longitude
		# EXIFR::JPEG.new(image).date_time

  end

end
