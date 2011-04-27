require 'rubygems'
require 'right_aws'
require 'active_record'
require 'yaml'

class Credentials
  def initialize
# TRIED USING THE INITIALIZE FOR THOSE YAML LOADING DOWN THERE
# BUT IT WAS GIVING ME CRAP AND HAD TO DUPLICATE THE LINE
# MY GUEST IS THAT IT IS B/C THEY ARE CLASS METHODS
# TODO: RESEARCH HOW TO REFACTOR OUT
  end

  def self.key
    @credentials = YAML::load(IO.read(File.dirname(__FILE__) + '/../support/aws.yml'))
    @credentials['test']['key']
  end
  def self.secret
    @credentials = YAML::load(IO.read(File.dirname(__FILE__) + '/../support/aws.yml'))
    @credentials['test']['secret']
  end
end


module LifeBoat
  def self.included(base)
    raise "Object Lacks Proper Callbacks" unless base.respond_to? :after_create
    base.class_eval do
      after_create :create_lifeboat
      before_destroy :destroy_lifeboat
      after_update :update_lifeboat
    end
  end

  def self.credentials(key, secret)
    @cue = RightAws::SqsGen2.new(key,secret)
  end

  def self.read_queue(name)
    @cue = RightAws::SqsGen2.new(Credentials.key, Credentials.secret)
    return @cue.queue(name).receive_messages
  end

  # THE FOLLOWING 3 METHODS LOOK A LOT A LIKE
  # A JUICY STEAK AWATING TO BE EATEN
  # DUPLICATION SOON TO BE REMOVED
  #
  #  MACHETE!

  def create_lifeboat
    @cue = RightAws::SqsGen2.new(Credentials.key, Credentials.secret)
    q = RightAws::SqsGen2::Queue.create(@cue, "create_" + self.class.to_s.downcase, true)
    q.send_message(self.attributes.to_json)
  end

  def update_lifeboat
    @cue = RightAws::SqsGen2.new(Credentials.key, Credentials.secret)
    q = RightAws::SqsGen2::Queue.create(@cue, "update_" + self.class.to_s.downcase, true)
    q.send_message(self.attributes.to_json)
  end

  def destroy_lifeboat
    @cue = RightAws::SqsGen2.new(Credentials.key, Credentials.secret)
    q = RightAws::SqsGen2::Queue.create(@cue, "destroy_" + self.class.to_s.downcase, true)
    q.send_message(self.attributes.to_json)
  end

end



