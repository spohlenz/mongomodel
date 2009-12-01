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

Spec::Runner.configure do |config|
  include DefineClass
  
  config.before(:each) do
    MongoModel.database.collections.each { |c| c.remove }
  end
end
