class Trip < ActiveRecord::Base
  attr_accessible :name, :location, :start, :end
  attr_readonly :slug

  has_many :photos
  belongs_to :user

  validates_presence_of :name, :start, :end
  validates_uniqueness_of :slug

  before_create :create_slug

  def create_slug
    self.slug = (('a'..'z').to_a  + ('A'..'Z').to_a + (0..9).to_a).shuffle[0,8].join
    create_slug if Trip.find_by_slug(self.slug)
  end

  def to_param
    self.slug
  end
end
