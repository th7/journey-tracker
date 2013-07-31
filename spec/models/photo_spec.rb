require 'spec_helper'

describe Photo do
  it{should belong_to(:trip)}
  it{should have_one(:palette)}
  it{should validate_presence_of(:url)}

  describe '#exif_date=' do
    it 'accepts an exif formatted date and converts to unix time' do
      photo = Photo.new(url: 'fakeurl.jpg')
      expect{photo.exif_date=('2013:07:08 18:40:04')}.to change{photo.date}.to(1373308804) 
    end
  end
end
