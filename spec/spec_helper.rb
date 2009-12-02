require 'rubygems'
require 'spec'

# Require MongoModel library
require File.dirname(__FILE__) + '/../lib/mongomodel'

# Require spec helpers
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

# For the purposes of tests, we ignore fractions of a second when comparing Time objects
class Time
  def ==(other)
    super(other) || to_s == other.to_s
  end
end

class CustomClass
  attr_reader :name
  
  def initialize(name)
    @name = name
  end
  
  def ==(other)
    other.is_a?(self.class) && name == other.name
  end
  
  def to_mongo
    { :name => name }
  end
  
  def self.from_mongo(hash)
    new(hash[:name])
  end
  
  def self.cast(value)
    new(value.to_s)
  end
end

Spec::Runner.configure do |config|
  include DefineClass
  
  config.before(:each) do
    MongoModel.database.collections.each { |c| c.remove }
  end
end
