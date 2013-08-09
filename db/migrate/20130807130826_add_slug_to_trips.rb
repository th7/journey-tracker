class AddSlugToTrips < ActiveRecord::Migration
  def change
    change_table :trips do |t|
      t.string :slug
    end
  end
end
