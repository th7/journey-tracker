class Photo < ActiveRecord::Base
  require 'open-uri'

  attr_accessible :caption, :url, :trip_id, :lat, :long, :date
  belongs_to :trip
  has_one :palette

  after_save :get_photo_colors

  validates_presence_of :url
  validates_uniqueness_of :url

  def get_photo_colors
    Miro.options[:color_count] = 6
    colors = Miro::DominantColors.new(self.url).to_hex
    @palette = self.build_palette(color1: colors[0], color2: colors[1], color3: colors[2], color4: colors[3], color5: colors[4], color6: colors[5])
    @palette.save
  end

  def get_exif_data(photo)
  	# image = MiniMagick::Image.open(photo.url)
  	# image["EXIF:BitsPerSample"]
  	# EXIFR::JPEG.new(image).gps.latitude
		# EXIFR::JPEG.new(image).gps.longitude
		# EXIFR::JPEG.new(image).date_time
  end

end
