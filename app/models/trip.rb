class Trip < ActiveRecord::Base
  attr_accessible :name, :start, :end
  has_many :photos
  belongs_to :user

  validates_presence_of :name, :start, :end
end
