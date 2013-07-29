module PhotosHelper

  def process_photos(photos)
    next_index = 0
    photos.each_with_index do |photo, i|
      if photo.lat
        photo.map_index = next_index
        next_index += 1
      end
    end
    photos
  end

end