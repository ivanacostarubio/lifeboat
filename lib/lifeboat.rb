require 'rubygems'
require 'right_aws'
require 'active_record'
require 'yaml'
require 'fileutils'
require 'thread'

class AWS
  def self.root
    rails_root = (Rails.version < "2.1.2") ? RAILS_ROOT : Rails.root
    YAML::load(IO.read(File.join(rails_root, 'config', 'aws.yml')))
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
      AWS.root[RAILS_ENV]['access_key_id']
    end
    def self.secret
      AWS.root[RAILS_ENV]['secret_access_key']
    end
  rescue RightAws::AwsError
    puts"LIFEBOAT : AWS Access Key Id needs a subscription for the service."
  end
end


class RescateLifeBoat

  @queue = :lifeboats

  def self.perform(action, klass, id)
    record = klass.camelize.constantize.find(id)
    record.send(action)
  end
end


module LifeBoat

  def self.read_queue(name)
    #TODO EXTRAT OUT THE @CUE INTO HIGHER LEVEL
    @cue = RightAws::SqsGen2.new(Credentials.key, Credentials.secret)
    return @cue.queue(name).receive_messages
  end

  module ResqueCallbacks
    def create_resque_lifeboat
     if RAILS_ENV == "testing"
       self.create_lifeboat
     else
       Resque.enqueue(RescateLifeBoat, :create_lifeboat ,self.class.name, self.id)
     end
    end

    def destroy_resque_lifeboat
      if RAILS_ENV == "testing"
        self.destroy_lifeboat
      else
        Resque.enqueue(RescateLifeBoat, :destroy_lifeboat, self.class.name, self.id)
      end
    end

    def update_resque_lifeboat
      if RAILS_ENV == "testing"
        self.update_lifeboat
      else
        Resque.enqueue(RescateLifeBoat, :update_lifeboat ,self.class.name, self.id)
      end
    end
  end


  module ActiveRecord

    
    def has_lifeboat(options={})
      include LifeBoat::Queues

      if options[:format] == :xml
        format = :to_xml
      else
        format = :to_json
      end

      [:create, :update, :destroy ].each do |action|
        define_method(action.to_s + "_lifeboat") do
          begin
            return unless (RAILS_ENV == "production") or (RAILS_ENV == "testing")
            @cue = RightAws::SqsGen2.new(Credentials.key, Credentials.secret)
            queue_name = action.to_s+"_"+ self.class.to_s.downcase + "_" + RAILS_ENV
            q = RightAws::SqsGen2::Queue.create(@cue, queue_name, true, 1000)
            q.send_message(self.attributes.send format)
          rescue RightAws::AwsError => error
            puts error
          end
        end
      end
    end
  end

  module Queues
    def self.included(base)
      raise "Object Lacks Proper Callbacks" unless base.respond_to? :after_create
      base.class_eval do
        after_create :create_resque_lifeboat
        after_destroy :destroy_resque_lifeboat
        after_update :update_resque_lifeboat
      end
    end
  end
end

ActiveRecord::Base.extend LifeBoat::ActiveRecord
