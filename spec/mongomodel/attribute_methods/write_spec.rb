require 'spec_helper'

module MongoModel
  describe Document do
    define_class(:TestDocument, Document) do
      property :foo, String
    end
    
    subject { TestDocument.new }
    
    describe "#write_attribute" do
      context "with property" do
        it "should set the attribute hash" do
          subject.write_attribute(:foo, 'set foo')
          subject.attributes[:foo].should == 'set foo'
        end
        
        it "should define a writer method" do
          subject.foo = 'set foo'
          subject.attributes[:foo].should == 'set foo'
        end
      end
      
      context "no property" do
        it "should set the attribute hash" do
          subject.write_attribute(:bar, 'set bar')
          subject.attributes[:bar].should == 'set bar'
        end
        
        it "should not define a writer method" do
          subject.should_not respond_to(:bar)
        end
      end
    end
    
    describe "#[]=" do
      it "should write the given attribute" do
        subject.should_receive(:write_attribute).with(:foo, 'value of foo')
        subject[:foo] = 'value of foo'
      end
    end
  end
end
