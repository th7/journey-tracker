class Photo < ActiveRecord::Base
  attr_accessible :caption, :url, :lat, :long, :date
  belongs_to :trip

  validates_presence_of :url
  validates_uniqueness_of :url
end
