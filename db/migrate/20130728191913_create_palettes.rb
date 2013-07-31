class CreatePalettes < ActiveRecord::Migration
  def change
    create_table :palettes do |t|
      t.belongs_to :photo
      t.string :color1
      t.string :color2
      t.string :color3
      t.string :color4
      t.string :color5
      t.string :color6
      t.timestamps
    end
  end
end
