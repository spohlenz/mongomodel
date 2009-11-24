require 'spec_helper'

module MongoModel
  describe FinderOperator do
    subject { FinderOperator.new(:age, :gt) }
    
    it "should convert to mongo conditions" do
      subject.to_mongo_conditions(14).should == { '$gt' => 14 }
    end
    
    it "should be equal to a FinderOperator with the same field and operator" do
      subject.should == FinderOperator.new(:age, :gt)
    end
    
    it "should not be equal to a FinderOperator with a different field/operator" do
      subject.should_not == FinderOperator.new(:age, :lte)
      subject.should_not == FinderOperator.new(:date, :gt)
    end
    
    it "should be created from symbol methods" do
      :age.gt.should == FinderOperator.new(:age, :gt)
      :date.lte.should == FinderOperator.new(:date, :lte)
    end
    
    it "should be equal within a hash" do
      { :age.gt => 10 }.should == { :age.gt => 10 }
    end
  end
end
