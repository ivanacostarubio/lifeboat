require 'rubygems'
require 'right_aws'
require 'active_record'
require 'yaml'

class AWS
  def self.root
    if Rails.root
      YAML::load(IO.read(Rails.root + "config/aws.yml"))
    else
      YAML::load(IO.read(File.dirname(__FILE__) + '/../config/aws.yml'))
    end
  end
end



class Credentials
  def initialize
# TRIED USING THE INITIALIZE FOR THOSE YAML LOADING DOWN THERE
# BUT IT WAS GIVING ME CRAP AND HAD TO DUPLICATE THE LINE
# MY GUEST IS THAT IT IS B/C THEY ARE CLASS METHODS
# TODO: RESEARCH HOW TO REFACTOR OUT
  end

  def self.key
    AWS.root['test']['key']
  end
  def self.secret
    AWS.root['test']['secret']
  end
end


module LifeBoat
  def self.included(base)
    raise "Object Lacks Proper Callbacks" unless base.respond_to? :after_create
    base.class_eval do
      after_create :create_lifeboat
      after_destroy :destroy_lifeboat
      after_update :update_lifeboat
    end
  end

  def self.read_queue(name)
    #TODO EXTRAT OUT THE @CUE INTO HIGHER LEVEL
    @cue = RightAws::SqsGen2.new(Credentials.key, Credentials.secret)
    return @cue.queue(name).receive_messages
  end

  def after_initialize
    @cue = RightAws::SqsGen2.new(Credentials.key, Credentials.secret)
  end

  [:create, :update, :destroy ].each do |action|
    define_method(action.to_s + "_lifeboat") do
      q = RightAws::SqsGen2::Queue.create(@cue, action.to_s+"_"+ self.class.to_s.downcase, true)
      q.send_message(self.attributes.to_json)
    end
  end

end
