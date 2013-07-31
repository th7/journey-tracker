class Photo < ActiveRecord::Base
  require 'open-uri'

  attr_accessible :caption, :url, :trip_id, :lat, :long, :date, :exif_date
  belongs_to :trip
  has_one :palette

  # after_create :get_photo_colors

  validates_presence_of :url
  # validates_uniqueness_of :url

  def get_photo_colors
    Miro.options[:color_count] = 6
    colors = Miro::DominantColors.new(self.url).to_hex
    @palette = self.build_palette(color1: colors[0], color2: colors[1], color3: colors[2], color4: colors[3], color5: colors[4], color6: colors[5])
    @palette.save
  end

  def display_date
    if self.date == 0
      "Date not found"
    else
      Time.at(self.date)
    end
  end

  def exif_date=(date)
    p date
    self.date = DateTime.strptime(date,"%Y:%m:%d %T").to_i
    p self.date
  end

  # def set_gps_as_decimal(array,ref)
  #   decimal = array[0].to_f + array[1].to_f/60.0
    
  #   if ref == "N"
  #     self.lat = decimal
  #   elsif ref == "S"
  #     decimal = decimal*-1
  #     self.lat = decimal
  #   elsif ref == "E"
  #     self.long = decimal
  #   elsif ref == "W"
  #     decimal = decimal*-1
  #     # self.update_attributes(long: decimal)
  #     self.long = decimal
  #   else
  #     raise "GPS Ref error"
  #   end
      
  # end

end
