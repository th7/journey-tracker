class AddLocationToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :location, :string
  end
end
