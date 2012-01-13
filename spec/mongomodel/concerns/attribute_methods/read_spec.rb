require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    define_class(:TestDocument, described_class) do
      property :foo, String
    end
    
    subject { TestDocument.new(:foo => 'value of foo', :bar => 'value of bar') }
    
    describe "#read_attribute" do
      context "valid property" do
        it "should return the attribute value" do
          subject.read_attribute(:foo).should == 'value of foo'
        end
        
        it "should define a reader method" do
          subject.foo.should == 'value of foo'
        end
        
        it "should not overwrite an existing method" do
          TestDocument.send(:define_method, :foo) { "stubbed foo" }
          subject.foo.should == "stubbed foo"
        end
        
        define_class(:SubDocument, :TestDocument)
        
        it "should not overwrite an existing method on a superclass" do
          TestDocument.send(:define_method, :foo) { "stubbed foo" }
          SubDocument.new(:foo => "value of foo").foo.should == "stubbed foo"
        end
      end
      
      context "no property" do
        it "should return the attribute value" do
          subject.read_attribute(:bar).should == 'value of bar'
        end
        
        it "should not define a reader method" do
          lambda { subject.bar }.should raise_error(NoMethodError)
        end
      end
    end
    
    describe "#[]" do
      it "should read the given attribute" do
        subject.should_receive(:read_attribute).with(:foo).and_return('value of foo')
        subject[:foo].should == 'value of foo'
      end
    end
  end
  
  specs_for(Document) do
    define_class(:TestDocument, Document)
    
    subject { TestDocument.new }
    
    describe "#id" do
      it "should return id from attributes" do
        subject.id.should == subject.attributes[:id]
      end
    end
  end
end
