require 'spec_helper'

module MongoModel
  describe EmbeddedDocument do
    define_class(:TestDocument, Document) do
      property :foo, String
    end
    
    subject { TestDocument.new(:foo => 'value of foo', :bar => 'value of bar') }
    
    describe "#read_attribute" do
      context "valid property" do
        it "should return the attribute value" do
          subject.read_attribute(:foo).should == 'value of foo'
        end
        
        it "should have a reader method" do
          subject.foo.should == 'value of foo'
        end
      end
      
      context "no property" do
        it "should return the attribute value" do
          subject.read_attribute(:bar).should == 'value of bar'
        end
        
        it "should not have a reader method" do
          subject.should_not respond_to(:bar)
        end
      end
    end
    
    describe "#[]" do
      it "should read the given attribute" do
        subject.should_receive(:read_attribute).with(:foo).and_return('value of foo')
        subject[:foo].should == 'value of foo'
      end
    end
    
    describe "#id" do
      it "should return id from attributes" do
        subject.id.should == subject.attributes[:id]
      end
    end
  end
end
