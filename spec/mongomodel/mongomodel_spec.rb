require 'spec_helper'

describe MongoModel do
  it "should have a database accessor" do
    db = MongoModel.database
    db.host.should == 'localhost'
    db.port.should == 27017
    db.name.should == 'mydb'
  end
end
