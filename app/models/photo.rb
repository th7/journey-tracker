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
    colors_rgb = Miro::DominantColors.new(self.url).to_rgb
    colors_hsv = []
    colors = []
    colors_rgb.each_with_index { |col,index| colors_hsv[index] = rgb_to_hsv(col) }
    colors_hsv.sort_by!(&:last)
    colors_hsv.each_with_index { |col,index| colors[index] = hsv_to_rgb(col) }


    p "original: #{colors_rgb}"
    p "sorted: #{colors_hsv}"
    p "final: #{}"

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

def hsv_to_rgb(array)
  h = [0, [360.0, array[0]*360.0].min].max
  s = [0, [1, array[1]].min].max
  v = [0, [1, array[2]].min].max

  if s==0
    r = v
    g = v
    b = v
    return [(r*255).round,(g*255).round,(b*255).round]
  end

  h = h/60.0
  i = h.to_i.to_f
  f = h-i
  p = v*(1-s)
  q = v * (1 - s * f)
  t = v * (1 - s * (1 - f))

  case i.to_i
    when 0:
      r = v
      g = t
      b = p
 
    when 1:
      r = q
      g = v
      b = p
 
    when 2:
      r = p
      g = v
      b = t
 
    when 3:
      r = p
      g = q
      b = v
 
    when 4:
      r = t
      g = p
      b = v
 
    else:
      r = v
      g = p
      b = q

  return [(r*255).round,(g*255).round,(b*255).round] 
      
end  

def rgb_to_hsv(array)

  r = array[0].to_f/255.0
  g = array[1].to_f/255.0
  b = array[2].to_f/255.0

  max_val = [r,g,b].max
  min_val = [r,g,b].min

  h = max_val
  s = max_val
  v = max_val

  d = max_val-min_val

  if max_val == 0.0
    s = 0.0
  else
    s = d/max_val
  end

  if max_val == min_val
    h = 0.0
  else
    case max_val
    when r
      h = (g - b) / d + (g < b ? 6.0 : 0)
    when g
      h = (b - r) / d + 2.0
    when b
      h = (r - g) / d + 4.0
    else
      raise "Max does not match r,g or b"
    end

    h = h/6.0
  end

  return [h, s, v];

end  

  private

  def fix_imgur_url
    self.url = url.gsub(/(\.[^\.]*)\z/,'h\1') if url.match(/imgur/)
  end
end
