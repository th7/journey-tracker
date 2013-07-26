class Trip < ActiveRecord::Base
  attr_accessible :name, :start, :end
  has_many :photos
  belongs_to :user
end
