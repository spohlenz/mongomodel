require 'spec_helper'

describe MongoModel do
  describe "setting a custom database configuration" do
    before(:each) do
      MongoModel.configuration = {
        'host'     => '127.0.0.1',
        'database' => 'mydb'
      }
    end
    
    it "should should merge configuration with defaults" do
      MongoModel.configuration.host.should == '127.0.0.1'
      MongoModel.configuration.port.should == 27017
      MongoModel.configuration.database.should == 'mydb'
    end
    
    it "should establish database connection to given database" do
      database = MongoModel.database
      connection = database.connection

      connection.host.should == '127.0.0.1'
      connection.port.should == 27017
      database.name.should == 'mydb'
    end
  end
end
