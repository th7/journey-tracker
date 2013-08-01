class Photo < ActiveRecord::Base
  require 'open-uri'

  attr_accessible :caption, :url, :trip_id, :lat, :long, :date, :exif_date
  belongs_to :trip
  has_one :palette

  after_create :get_photo_colors
  before_create :fix_imgur_url
  validates_presence_of :url
  # validates_uniqueness_of :url

  def get_photo_colors
    Miro.options[:color_count] = 6
    colors = Miro::DominantColors.new(self.url).to_hex
    self.palette = self.build_palette(color1: colors[0], color2: colors[1], color3: colors[2], color4: colors[3], color5: colors[4], color6: colors[5])
    self.save
  end

  def display_date
    if self.date == 0
      "Date not found"
    else
      Time.at(self.date).strftime('%B %e, %Y')
    end
  end

  def exif_date=(date)
    p date
    self.date = DateTime.strptime(date,"%Y:%m:%d %T").to_i
    p self.date
  end

  private

  def fix_imgur_url
    self.url = url.gsub(/(\.[^\.]*)\z/,'h\1') if url.match(/imgur/)
  end
end
