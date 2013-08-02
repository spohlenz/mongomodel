require 'spec_helper'
require 'active_support/core_ext/hash/indifferent_access'

module MongoModel
  AttributeTypes = {
    String => "my string",
    Integer => 99,
    Float => 45.123,
    Symbol => :foobar,
    Boolean => false,
    Array => [ 1, 2, 3, "hello", :world, [99, 100] ],
    Hash => { :rabbit => 'hat', 'hello' => 12345 }.with_indifferent_access,
    Date => Date.today,
    CustomClass => CustomClass.new('hello'),
    # Pre-cast Time and DateTime to remove microseconds
    Time => Types::Time.new.cast(Time.now),
    DateTime => Types::DateTime.new.cast(DateTime.now.in_time_zone)
  }
  
  specs_for(Document, EmbeddedDocument) do
    define_class(:TestDocument, described_class)
    
    it "has an attributes store on the instance" do
      doc = TestDocument.new
      doc.attributes.should be_an_instance_of(MongoModel::Attributes::Store)
    end
    
    it "converts to mongo representation" do
      doc = TestDocument.new
      doc.to_mongo.should == doc.attributes.to_mongo
    end
    
    AttributeTypes.each do |type, value|
      describe "setting #{type} attributes" do
        define_class(:TestDocument, described_class) do
          property :test_property, type
        end
        
        if specing?(EmbeddedDocument)
          define_class(:ParentDocument, Document) do
            property :child, TestDocument
          end
          
          let(:parent) { ParentDocument.create!(:child => TestDocument.new(:test_property => value)) }
          let(:child) { parent.child }
          let(:reloaded) { ParentDocument.find(parent.id).child }
          
          subject { child }
        else
          subject { TestDocument.create!(:test_property => value) }
          
          let(:reloaded) { TestDocument.find(subject.id) }
        end
        
        it "reads the correct value from attributes" do
          subject.test_property.should == value
        end
      
        it "reads the correct value after reloading" do
          reloaded.test_property.should == subject.test_property
        end
      end
    end
    
    it "has an attributes store" do
      doc = TestDocument.new
      doc.attributes.should be_an_instance_of(MongoModel::Attributes::Store)
    end
    
    it "duplicates attributes when duplicating object" do
      original = TestDocument.new
      duplicate = original.dup
      
      duplicate.attributes.should_not equal(original.attributes)
    end
    
    describe "initializing" do
      define_class(:Person, EmbeddedDocument) do
        property :name, String
        property :age, Integer, :default => 21
      end
      
      it "is initializable with attributes hash" do
        doc = Person.new(:name => 'Fred', :age => 42)
        doc.name.should == 'Fred'
        doc.age.should == 42
      end
      
      it "uses default attributes when initializing with partial attributes hash" do
        doc = Person.new(:name => 'Maurice')
        doc.age.should == 21
      end
      
      it "loads from mongo representation" do
        doc = Person.from_mongo({ 'name' => 'James', 'age' => 15 })
        doc.name.should == 'James'
        doc.age.should == 15
      end
    end
    
    describe "setting attributes with hash" do
      define_class(:TestDocument, described_class) do
        property :test_property, String
        
        def test_property=(value)
          write_attribute(:test_property, 'set from method')
        end
      end
      
      subject { TestDocument.new }
      
      it "calls custom property methods" do
        subject.attributes = { :test_property => 'property value' }
        subject.test_property.should == 'set from method'
      end
      
      it "uses write_attribute if no such property" do
        subject.attributes = { :non_property => 'property value' }
        subject.read_attribute(:non_property).should == 'property value'
      end
      
      if defined?(ActiveModel::ForbiddenAttributesProtection)
        it "raises ActiveModel::ForbiddenAttributesError when passed an unpermitted strong_params hash" do
          expect {
            subject.attributes = double(:permitted? => false)
          }.to raise_error(ActiveModel::ForbiddenAttributesError)
        end
      end
    end
    
    describe "#new" do
      define_class(:TestDocument, described_class)
      
      it "yields the instance to a block if provided" do
        block_called = false
        
        TestDocument.new do |doc|
          block_called = true
          doc.should be_an_instance_of(TestDocument)
        end
        
        block_called.should be_true
      end
    end
    
    context "a frozen instance" do
      define_class(:TestDocument, described_class) do
        property :test_property, String
      end
      
      subject { TestDocument.new(:test_property => 'Test') }
      
      before(:each) { subject.freeze }
      
      it { should be_frozen }
      
      it "does not allow changes to the attributes hash" do
        lambda { subject.attributes[:test_property] = 'Change' }.should raise_error
      end
    end
  end
end
