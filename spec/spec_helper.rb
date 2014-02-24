require 'rubygems'
require 'bundler/setup'
Bundler.setup

require 'rspec'

require 'mongomodel'

# Require spec helpers
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

require 'active_support/time'
Time.zone = "Australia/Melbourne"

I18n.config.enforce_available_locales = false

RSpec.configure do |config|
  include SpecsFor
  include DefineClass
  
  config.before(:all) do
    MongoModel.configuration.use_database('mongomodel-specs')
  end
  
  config.before(:each) do
    MongoModel.database.collections.each { |c| c.drop rescue c.remove }
  end
end
