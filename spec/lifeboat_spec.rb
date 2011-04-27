require 'rubygems'
require 'rspec'
require 'lifeboat'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/../support/database.yml'))
ActiveRecord::Base.logger =
        ActiveSupport::BufferedLogger.new(File.dirname(__FILE__) + "/debug.log")

ActiveRecord::Base.establish_connection(config['test'])

def rebuild_model options = {}
  ActiveRecord::Base.connection.create_table :fake_models, :force => true do |table|
    table.column :name, :string
    table.column :phone, :string
    table.column :email, :string
  end
  ActiveRecord::Base.connection.create_table :fakes, :force => true do |table|
    table.column :name, :string
  end
end

rebuild_model

class FakeModel < ActiveRecord::Base
  attr_accessor :name, :email, :phone
  include LifeBoat
end

class Fake < ActiveRecord::Base
  attr_accessor :name
  include LifeBoat
end


class Helper
def self.clean_all_queues
   @sqs = RightAws::SqsGen2.new(Credentials.key,Credentials.secret)
   @sqs.queues.each do |queue|
     @sqs.queue(queue.name.to_s).clear
   end
end
end

describe "An simple object " do
  it "raises for not having callbacks" do
    lambda{ class BadModel ; include LifeBoat ; end }.should raise_error
  end
end

describe FakeModel, " We hook into callbacks to send the messages" do

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

describe LifeBoat, " Create" do
  before(:each) do
    Helper.clean_all_queues
  end

  it "the message it creates contains the attributes ob the object as json" do
    f = Fake.create(:name => "ivan")
    q = LifeBoat.read_queue("create_fake")
    q[0].body.should == f.attributes.to_json
  end
end

describe LifeBoat  do

  before(:each) do
    Helper.clean_all_queues
  end

  it "reads messages from a cue" do
    Fake.create(:name => "ivan")
    messages = LifeBoat.read_queue("create_fake")
    messages.size.should == 1
  end

  it "Raises when no credentials are given" do
    lambda { LifeBoat.credentials('','')}.should raise_error(RightAws::AwsError)
  end

  it "updates SQS message object when parent is updated" do
    pending
  end

  it "deletes SQS message object when parent is deleted" do
    pending
  end

end
