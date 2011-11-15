require 'rubygems'
require 'rspec'

RAILS_ENV = "testing"

require 'lifeboat'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/../config/database.yml'))

ActiveRecord::Base.logger =
        ActiveSupport::BufferedLogger.new(File.dirname(__FILE__) + "/debug.log")

ActiveRecord::Base.establish_connection(config['test'])

def rebuild_model options = {}
 #   ActiveRecord::Base.connection.create_database('lifeboat_test')
  ActiveRecord::Base.connection.create_table :fake_models, :force => true do |table|
    table.column :name, :string
    table.column :phone, :string
    table.column :email, :string
  end
  ActiveRecord::Base.connection.create_table :fakes, :force => true do |table|
    table.column :name, :string
  end
  ActiveRecord::Base.connection.create_table :xml_records, :force => true do |table|
    table.column :name, :string
  end

end

rebuild_model

class FakeModel < ActiveRecord::Base
  include LifeBoat::ResqueCallbacks
  attr_accessor :name, :email, :phone
  has_lifeboat
end

class Fake < ActiveRecord::Base
  include LifeBoat::ResqueCallbacks
  attr_accessor :name
  has_lifeboat
end

class XMLRecord < ActiveRecord::Base
  include LifeBoat::ResqueCallbacks
  attr_accessor :name
  has_lifeboat :format => :xml
end


class Helper
    def self.clean_all_queues
       @sqs = RightAws::SqsGen2.new(Credentials.key,Credentials.secret)
       @sqs.queues.each do |queue|
         @sqs.queue(queue.name.to_s).clear
       end
    end
end

class Rails
  def self.root
    Dir.pwd
  end

  def self.version
    '2.1.2'
  end
end

describe "An simple object " do
  it "raises for not having callbacks" do
    lambda{ class BadModel ; has_lifeboat ; end }.should raise_error
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

describe LifeBoat , " AWS Credentials"do
  before(:each) do
    Helper.clean_all_queues
  end

  it "Read the credentials from config/aws.yml" do
    pending
  end
end

describe LifeBoat  do

  after(:each) do
    Helper.clean_all_queues
  end

  it "reads messages from a cue" do
    Fake.create(:name => "ivan")
    messages = LifeBoat.read_queue("create_fake_testing")
    messages.size.should == 1
  end

  it "the message it creates contains the attributes ob the object as json" do
    f = Fake.create(:name => "ivan")
    q = LifeBoat.read_queue("create_fake_testing")
    q[0].body.should == f.attributes.to_json
  end

  it "creates a destroy SQS queue when parent is destroyed" do
    f = Fake.create(:name => "updated")
    f.destroy
    messages = LifeBoat.read_queue("destroy_fake_testing")
    messages.size.should == 1
  end

  it "updates SQS queue when parent is updated" do
    f = Fake.create(:name => "Er Update")
    f.name= "28347834" ; f.save
    messages= LifeBoat.read_queue("update_fake_testing")
    messages.size.should == 1
  end
end

describe LifeBoat, " does XML" do 
  it "serialices the objects to xml" do 
    f = XMLRecord.create(:name => "Yo soy XML")
    messages = LifeBoat.read_queue("create_xmlrecord_testing")
    messages.size.should == 1
    messages[0].body.should == f.attributes.to_xml
  end
end
