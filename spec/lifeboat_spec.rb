require 'rubygems'
require 'rspec'

module LifeBoat
end

describe LifeBoat do
  it "creates a fake object inheriting from active record" do
    @i = LifeBoat.create_fake
    @i.class.class.should == ActiveRecord
  end

  it "reads all attributes from included object" do
    pending
  end
  it "creates simple DB object when parent is created" do
    pending
  end
  it "updates simple DB object when parent is updated" do
    pending
  end
  it "deletes simple DB object when parent is deleted" do
    pending
  end
end
