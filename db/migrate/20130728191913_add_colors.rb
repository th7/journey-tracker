class AddColors < ActiveRecord::Migration
  def up
  	add_column :photos, :color1, :string
  	add_column :photos, :color2, :string
  	add_column :photos, :color3, :string
  	add_column :photos, :color4, :string
  end

  def down
  	remove_column :photos, :color1
  	remove_column :photos, :color2
  	remove_column :photos, :color3
  	remove_column :photos, :color4
  end
end
