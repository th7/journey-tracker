class Trip < ActiveRecord::Base
  attr_accessible :name, :start, :end
  has_many :photos
  belongs_to :user

  validates_presence_of :name, :start, :end
 
  def self.json_storage(id, json_object = nil)
    @all_json_objects ||= {}
    json_object = @all_json_objects["#{id}"] if json_object == nil
    @all_json_objects["#{id}"] = json_object
    @all_json_objects["#{id}"] 
  end

end
