require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    if specing?(Document)
      define_class(:TestDocument, Document) do
        property :foo, String
        property :bar, String
      end

      subject { TestDocument.create!(:foo => 'original foo') }
      
    else
      define_class(:ChildDocument, EmbeddedDocument) do
        property :foo, String
        property :bar, String
      end
      
      define_class(:ParentDocument, Document) do
        property :child, ChildDocument
      end
      
      let(:child) { ChildDocument.new(:foo => 'original foo') }
      let(:parent) { ParentDocument.create!(:child => child) }
      
      subject { parent.child }
    end
    
    describe "#write_attribute" do
      before(:each) do
        subject.write_attribute(:foo, 'new foo')
      end
      
      it "should add the old attribute name to the changed attributes" do
        subject.changed.should include(:foo)
      end
      
      it "should not add other attributes to the changed attributes" do
        subject.changed.should_not include(:bar)
      end
      
      it "should add the changed attribute value to the changes hash" do
        subject.changes[:foo].should == ['original foo', 'new foo']
      end
      
      context "when called twice" do
        before(:each) do
          subject.write_attribute(:foo, 'new foo #2')
        end
        
        it "should keep the original value as the old value in the changes hash" do
          subject.changes[:foo].should == ['original foo', 'new foo #2']
        end
      end
    end
    
    context "with changed attributes" do
      context "attribute set to a new value" do
        before(:each) do
          subject.foo = 'foo changed'
        end
      
        it { should be_changed }
      end
      
      context "attribute set to the original value" do
        before(:each) do
          subject.foo = 'original foo'
        end
        
        it { should_not be_changed }
      end
    end
    
    context "without changed attributes" do
      it { should_not be_changed }
    end
    
    context "#original_attributes" do
      context "with changes" do
        before(:each) do
          subject.foo = 'changed foo'
        end
        
        it "should return the attributes before changes" do
          subject.original_attributes[:foo].should == 'original foo'
        end
      end
      
      context "without changes" do
        it "should return the attributes hash" do
          subject.original_attributes.should == subject.attributes
        end
      end
    end
  end
  
  specs_for(Document) do
    define_class(:TestDocument, Document) do
      property :foo, String
    end
    
    subject { TestDocument.create!(:foo => 'original foo') }
    
    context "when saved" do
      before(:each) do
        subject.foo = 'changed foo'
      end
      
      context "with save" do
        it "should reset the changed attributes" do
          subject.save
          subject.should_not be_changed
        end
      end
      
      context "with save!" do
        it "should reset the changed attributes" do
          subject.save!
          subject.should_not be_changed
        end
      end
    end
    
    context "when instantiated from database" do
      it "should not be changed" do
        instance = TestDocument.find(subject.id)
        instance.should_not be_changed
      end
    end
  end
end
