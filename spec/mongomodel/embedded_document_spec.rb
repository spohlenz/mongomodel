require 'spec_helper'

module MongoModel
  specs_for(EmbeddedDocument, Document) do
    describe "equality" do
      define_class(:DocumentA, described_class) do
        property :name, String
      end
      
      define_class(:DocumentB, described_class) do
        property :name, String
      end
    
      subject { DocumentA.new(:id => 'test', :name => 'Test') }
    
      it "should be equal to another document of the same class with identical attributes" do
        subject.should == DocumentA.new(:id => 'test', :name => 'Test')
      end
      
      it "should not be equal to another document of the same class with different attributes" do
        subject.should_not == DocumentA.new(:id => 'test', :name => 'Different')
        subject.should_not == DocumentA.new(:id => 'test', :name => 'Test', :special_attribute => 'Different')
      end
      
      it "should not be equal to another document of a different class with identical attributes" do
        subject.should_not == DocumentB.new(:id => 'test', :name => 'Different')
      end
    end
  end
  
  specs_for(EmbeddedDocument) do
    describe "single collection inheritance" do
      define_class(:Event, EmbeddedDocument)
      define_class(:SpecialEvent, :Event)
      
      define_class(:Parent, Document) do
        property :event, Event
      end
      
      let(:event) { Event.new }
      let(:special) { SpecialEvent.new }
      let(:parent) { Parent.new(:event => special) }
      let(:reloaded) { parent.save!; Parent.find(parent.id) }
      
      it "should not typecast to parent type when assigning to property" do
        parent.event.should be_an_instance_of(SpecialEvent)
      end
      
      it "should be an instance of the correct class when reloaded" do
        reloaded.event.should be_an_instance_of(SpecialEvent)
      end
    end
  end
end
