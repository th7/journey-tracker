class Photo < ActiveRecord::Base
   attr_accessible :caption, :url, :lat, :long, :date
  belongs_to :journey
end
