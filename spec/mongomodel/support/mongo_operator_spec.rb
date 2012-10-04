require 'spec_helper'

module MongoModel
  describe MongoOperator do
    subject { MongoOperator.new(:age, :gt) }
  
    it "converts to mongo selector" do
      subject.to_mongo_selector(14).should == { '$gt' => 14 }
    end
  
    it "is equal to a MongoOperator with the same field and operator" do
      subject.should == MongoOperator.new(:age, :gt)
    end
  
    it "is not equal to a MongoOperator with a different field/operator" do
      subject.should_not == MongoOperator.new(:age, :lte)
      subject.should_not == MongoOperator.new(:date, :gt)
    end
  
    it "is created from symbol methods" do
      :age.gt.should == MongoOperator.new(:age, :gt)
      :date.lte.should == MongoOperator.new(:date, :lte)
      :position.near.should == MongoOperator.new(:position, :near)
    end
  
    it "is equal within a hash" do
      { :age.gt => 10 }.should == { :age.gt => 10 }
    end
  end
end
