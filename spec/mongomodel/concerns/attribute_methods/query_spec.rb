require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    define_class(:TestDocument, described_class) do
      property :foo, String
      property :boolean, Boolean
    end
    
    subject { TestDocument.new }
    
    describe "#query_attribute" do
      context "string attribute" do
        it "returns true if the attribute is not blank" do
          subject.foo = 'set foo'
          subject.query_attribute(:foo).should be_true
          subject.foo?.should be_true
        end
      
        it "returns false if the attribute is nil" do
          subject.foo = nil
          subject.query_attribute(:foo).should be_false
          subject.foo?.should be_false
        end
      
        it "returns false if the attribute is blank" do
          subject.foo = ''
          subject.query_attribute(:foo).should be_false
          subject.foo?.should be_false
        end
      end
      
      context "boolean attribute" do
        it "returns true if the attribute is true" do
          subject.boolean = true
          subject.query_attribute(:boolean).should be_true
          subject.boolean?.should be_true
        end
        
        it "returns false if the attribute is nil" do
          subject.boolean = nil
          subject.query_attribute(:boolean).should be_false
          subject.boolean?.should be_false
        end
      
        it "returns false if the attribute is false" do
          subject.boolean = false
          subject.query_attribute(:boolean).should be_false
          subject.boolean?.should be_false
        end
      end
    end
  end
end
