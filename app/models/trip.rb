class Trip < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :photos
  belongs_to :user
end
