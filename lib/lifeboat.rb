require 'rubygems'
require 'right_aws'
require 'active_record'
require 'yaml'
require 'fileutils'
require 'thread'

class AWS

  # DUPLICATION IS RISING ON THE self.root METHOD
  # MACHETE 
  def self.root
    if Rails.version == "2.1.2"
      YAML::load(IO.read(Rails.root + "/config/aws.yml"))
    elsif Rails.version == "2.3.8"
      YAML::load(IO.read(Rails.root + "config/aws.yml"))
    else
      raise "Email ivan@bakedweb.net with this error"
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

  begin
    def self.key
      AWS.root[RAILS_ENV]['key']
    end
    def self.secret
      AWS.root[RAILS_ENV]['secret']
    end
  rescue RightAws::AwsError
    puts"LIFEBOAT : AWS Access Key Id needs a subscription for the service."
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

  begin
    [:create, :update, :destroy ].each do |action|
      define_method(action.to_s + "_lifeboat") do
        q = RightAws::SqsGen2::Queue.create(@cue, action.to_s+"_"+ self.class.to_s.downcase, true)
        q.send_message(self.attributes.to_json)
      end
    end
  rescue RightAws::AwsError
    puts "LifeBoat RightAws::AwsError TIMEOUT"
  end

end
