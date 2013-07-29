class PhotoPresenter
  attr_accessor :map_index

  def initialize(photo)
    @photo = photo
    @map_index = nil
  end

  def method_missing(name, *args, &block)
    if @photo.respond_to?(name)
      @photo.send(name, *args, &block)
    end
  end

end