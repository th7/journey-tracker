class Palette < ActiveRecord::Base
	belongs_to :photo

	attr_accessible :color1, :color2, :color3, :color4, :color5, :color6



end