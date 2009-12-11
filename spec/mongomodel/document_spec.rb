require 'spec_helper'

module MongoModel
  specs_for(Document) do
    it "should inherit from EmbeddedDocument" do
      Document.ancestors.should include(EmbeddedDocument)
    end
    
    it "should have an id property" do
      property = Document.properties[:id]
      property.name.should == :id
      property.as.should == '_id'
      property.default(mock('instance')).should_not be_nil
    end
    
    describe "single collection inheritance" do
      define_class(:Event, Document)

      define_class(:SpecialEvent, :Event) do
        property :decription, String
      end
      
      let(:event) { Event.create! }
      let(:special) { SpecialEvent.create!(:description => 'Woo') }
      let(:missing) do
        e = Event.new
        e.type = 'MissingClass'
        e.save!
        e
      end
      
      it "should belong to the same collection as its parent" do
        SpecialEvent.collection_name.should == Event.collection_name
      end
      
      it "should be an instance of the correct class when loaded" do
        Event.find(event.id).should be_an_instance_of(Event)
        Event.find(special.id).should be_an_instance_of(SpecialEvent)
      end
      
      it "should default to superclass type if type missing" do
        Event.find(missing.id).should be_an_instance_of(Event)
      end
      
      it "should consider document missing when finding from subclass using id of parent instance" do
        lambda { SpecialEvent.find(event.id) }.should raise_error(MongoModel::DocumentNotFound)
      end
    end
  end
end
