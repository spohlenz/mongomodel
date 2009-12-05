require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    define_class(:TestDocument, described_class) do
      property :foo, String
    end
    
    subject { TestDocument.new }
    
    describe "#query_attribute" do
      it "should return true if the attribute is not blank" do
        subject.foo = 'set foo'
        subject.query_attribute(:foo).should be_true
      end
      
      it "should return false if the attribute is blank" do
        subject.foo = ''
        subject.query_attribute(:foo).should be_false
      end
      
      it "should create a query method" do
        subject.foo?.should == subject.query_attribute(:foo)
      end
    end
  end
end
