require 'spec_helper'
describe Trip do
  it { should have_many(:photos) }
  it {should belong_to(:user)}
  it{should validate_presence_of(:name)}
  it{should validate_presence_of(:start)}
  it{should validate_presence_of(:end)}
end
