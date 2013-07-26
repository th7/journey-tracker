class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :trip_id
      t.string :caption
      t.string :url
      t.integer :date
      t.float :lat
      t.float :long
      t.timestamps
    end

  end
end
