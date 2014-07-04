require 'spec_helper'

module MongoModel
  describe Configuration do
    it "uses a standard connection (Mongo::MongoClient) if no replicas are specified" do
      Configuration.new({}).connection.should be_an_instance_of(Mongo::MongoClient)
    end
    
    it "uses a replica set connection (Mongo::MongoReplicaSetClient) if replicas are specified" do
      Configuration.new({ :replicas => ['127.0.0.1:27017'] }).connection.should be_an_instance_of(Mongo::MongoReplicaSetClient)
    end
  end
end
