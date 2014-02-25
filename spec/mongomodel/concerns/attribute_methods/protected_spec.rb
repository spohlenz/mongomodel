require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    define_class(:TestDocument, described_class) do
      property :foo, String
      property :bar, String
    end
  
    subject { TestDocument.new }
  
    describe "#attr_protected" do
      before(:each) do
        TestDocument.attr_protected :foo
      end
    
      it "disallows the attribute to be mass-assigned via attributes=" do
        subject.attributes = { :foo => 'value of foo' }
        subject.foo.should be_nil
      end
    
      it "does not disallow the attribute to be assigned individually" do
        subject.foo = 'value of foo'
        subject.foo.should == 'value of foo'
      end
    
      it "does not disallow other attributes to be mass-assigned via attributes=" do
        subject.attributes = { :bar => 'value of bar' }
        subject.bar.should == 'value of bar'
      end
    
      it "accepts multiple attributes" do
        TestDocument.attr_protected :foo, :bar
      
        subject.attributes = { :foo => 'value of foo', :bar => 'value of bar' }
        subject.foo.should be_nil
        subject.bar.should be_nil
      end
    end
  
    describe "#attr_accessible" do
      before(:each) do
        TestDocument.attr_accessible :foo
      end
    
      it "allows the attribute to be mass-assigned via attributes=" do
        subject.attributes = { :foo => 'value of foo' }
        subject.foo.should == 'value of foo'
      end
    
      it "does not disallow other attributes to be mass-assigned via attributes=" do
        subject.attributes = { :bar => 'value of bar' }
        subject.bar.should be_nil
      end
    
      it "does not disallow others attributes to be assigned individually" do
        subject.bar = 'value of bar'
        subject.bar.should == 'value of bar'
      end
    
      it "accepts multiple attributes" do
        TestDocument.attr_accessible :foo, :bar
      
        subject.attributes = { :foo => 'value of foo', :bar => 'value of bar' }
        subject.foo.should == 'value of foo'
        subject.bar.should == 'value of bar'
      end
    end
  
    describe "#property" do
      context "with :protected option" do
        it "makes the attribute protected" do
          TestDocument.should_receive(:attr_protected).with(:baz)
          TestDocument.property :baz, String, :protected => true
        end
      end
    
      context "with :accessible option" do
        it "makes the attribute accessible" do
          TestDocument.should_receive(:attr_accessible).with(:baz)
          TestDocument.property :baz, String, :accessible => true
        end
      end
    end
  end
end
