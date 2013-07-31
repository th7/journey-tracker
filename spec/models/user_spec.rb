require 'spec_helper'
describe User do
   it { should have_many(:trips) }
   it { should have_many(:photos).through(:trips) }
end
