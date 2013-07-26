module PhotosHelper

  def process(photos)
    @photos ||= photos
    slides = []
    next_index = 0
    @photos.each_with_index do |photo, i|
      item = {}
      item.store(:url, photo.url)
      if photo.lat
        item.store(:map_index, next_index)
        next_index += 1
      end
      slides << item
    end
    slides
  end

end