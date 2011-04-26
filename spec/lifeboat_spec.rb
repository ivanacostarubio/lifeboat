require 'rubygems'
require 'active_record'
require 'rspec'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/../support/database.yml'))
ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(File.dirname(__FILE__) + "/debug.log")

ActiveRecord::Base.establish_connection(config['test'])

def rebuild_model options = {}
  ActiveRecord::Base.connection.create_table :fake_models, :force => true do |table|
    table.column :name, :string
    table.column :phone, :string
    table.column :email, :string
  end
end

rebuild_model

class FakeModel < ActiveRecord::Base
  attr_accessor :name, :email, :phone
end


module LifeBoat
  def self.included(mod)
    raise "Object Lacks Proper Callbacks" unless mod.respond_to? :after_create
  end
end


describe "BadModel" do
  it "raises for not having callbacks" do
    lambda{ class BadModel ; include LifeBoat ; end }.should raise_error
  end
end

describe FakeModel, "We hook into callbacks to send the messages" do

  it "does not raise when included in object with proper callbacks" do
    lambda{ class FakeModel < ActiveRecord::Base ; include LifeBoat; end }.should_not raise_error
  end
  it "Fake Model responds to :after_create" do
    after_create = FakeModel.respond_to? :after_create
    after_create.should == true
  end

  it "Fake Model responds to :after_update" do
    after_update = FakeModel.respond_to? :after_update
    after_update.should == true
  end

  it "Fake Model Responds to :after_destroy" do
    after_destroy = FakeModel.respond_to? :after_destroy
    after_destroy.should == true
  end
end

describe LifeBoat do

  it "reads all attributes from included object" do
    pending
  end
  it "creates SQS message object when parent is created" do
    pending
  end
  it "updates SQS message object when parent is updated" do
    pending
  end
  it "deletes SQS message object when parent is deleted" do
    pending
  end
end
