class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.integer :user_id
      t.string :name
      t.datetime :start
      t.datetime :end
      t.timestamps
    end
  end
end
