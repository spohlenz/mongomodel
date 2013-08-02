require 'spec_helper'

module MongoModel
  specs_for(Document) do
    it "inherits from EmbeddedDocument" do
      Document.ancestors.should include(EmbeddedDocument)
    end
    
    it "has an id property" do
      property = Document.properties[:id]
      property.name.should == :id
      property.as.should == '_id'
      property.default(double('instance', :generate_id => 'abc-123')).should == 'abc-123'
    end
    
    describe "equality" do
      define_class(:DocumentA, Document)
      define_class(:DocumentB, Document)
    
      subject { DocumentA.new(:id => 'test') }
    
      it "is equal to another document of the same class with the same id" do
        subject.should == DocumentA.new(:id => 'test')
      end
      
      it "is not equal to another document of the same class with a different id" do
        subject.should_not == DocumentA.new(:id => 'not-test')
      end
      
      it "is not equal to another document of a different class with the same id" do
        subject.should_not == DocumentB.new(:id => 'test')
      end
    end
    
    describe "single collection inheritance" do
      define_class(:Event, Document)
      define_class(:SpecialEvent, :Event)
      define_class(:VerySpecialEvent, :SpecialEvent)
      define_class(:SuperSpecialEvent, :VerySpecialEvent)
      
      let(:missing) do
        e = Event.new
        e.type = 'MissingClass'
        e.save!
        e
      end
      
      before(:each) do
        @event = Event.create!
        @special = SpecialEvent.create!
        @very_special = VerySpecialEvent.create!
        @super_special = SuperSpecialEvent.create!
        @missing = missing
      end
      
      it "belongs to the same collection as its parent" do
        SpecialEvent.collection_name.should == Event.collection_name
        VerySpecialEvent.collection_name.should == Event.collection_name
      end
      
      it "is an instance of the correct class when loaded" do
        Event.find(@event.id).should be_an_instance_of(Event)
        Event.find(@special.id).should be_an_instance_of(SpecialEvent)
        Event.find(@very_special.id).should be_an_instance_of(VerySpecialEvent)
        
        SpecialEvent.find(@special.id).should be_an_instance_of(SpecialEvent)
        SpecialEvent.find(@very_special.id).should be_an_instance_of(VerySpecialEvent)
        
        VerySpecialEvent.find(@very_special.id).should be_an_instance_of(VerySpecialEvent)
      end
      
      it "defaults to superclass type if type missing" do
        Event.find(@missing.id).should be_an_instance_of(Event)
      end
      
      it "considers document missing when finding from subclass using id of parent instance" do
        lambda { SpecialEvent.find(@event.id) }.should raise_error(MongoModel::DocumentNotFound)
        lambda { VerySpecialEvent.find(@special.id) }.should raise_error(MongoModel::DocumentNotFound)
      end
      
      describe "loading documents" do
        it "loads all documents from root class" do
          Event.all.should include(@event, @special, @very_special, @super_special, @missing)
        end
        
        it "only loads subclass documents from subclass" do
          SpecialEvent.all.should include(@special, @very_special, @super_special)
          SpecialEvent.all.should_not include(@event, @missing)
          
          VerySpecialEvent.all.should include(@very_special, @super_special)
          VerySpecialEvent.all.should_not include(@event, @special, @missing)
          
          SuperSpecialEvent.all.should == [@super_special]
        end
      end
    end
  end
end
