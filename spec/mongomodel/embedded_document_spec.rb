require 'spec_helper'

module MongoModel
  specs_for(EmbeddedDocument, Document) do
    it "is an abstract class" do
      described_class.should be_an_abstract_class
    end

    it "instantiates with nil" do
      described_class.new(nil).should be_an_instance_of(described_class)
    end

    describe "subclasses" do
      define_class(:TestDocument, described_class)

      it "is not an abstract class" do
        TestDocument.should_not be_an_abstract_class
      end
    end
  end

  specs_for(EmbeddedDocument) do
    define_class(:Event, EmbeddedDocument)
    define_class(:SpecialEvent, :Event)

    define_class(:Parent, Document) do
      property :event, Event
      property :events, Collection[Event], :default => []
    end

    let(:event) { Event.new }
    let(:special) { SpecialEvent.new }
    let(:parent) { Parent.new(:event => special) }
    let(:reloaded) { parent.save!; Parent.find(parent.id) }

    describe "equality" do
      define_class(:DocumentA, EmbeddedDocument) do
        property :name, String
      end

      define_class(:DocumentB, EmbeddedDocument) do
        property :name, String
      end

      subject { DocumentA.new(:id => 'test', :name => 'Test') }

      it "is equal to another document of the same class with identical attributes" do
        subject.should == DocumentA.new(:id => 'test', :name => 'Test')
      end

      it "is not equal to another document of the same class with different attributes" do
        subject.should_not == DocumentA.new(:id => 'test', :name => 'Different')
        subject.should_not == DocumentA.new(:id => 'test', :name => 'Test', :special_attribute => 'Different')
      end

      it "is not equal to another document of a different class with identical attributes" do
        subject.should_not == DocumentB.new(:id => 'test', :name => 'Different')
      end
    end

    describe "single collection inheritance" do
      it "does not typecast to parent type when assigning to property" do
        parent.event.should be_an_instance_of(SpecialEvent)
      end

      it "is an instance of the correct class when reloaded" do
        reloaded.event.should be_an_instance_of(SpecialEvent)
      end
    end

    describe "parent document" do
      context "on an embedded document" do
        it "sets the parent document on the embedded document" do
          parent.event.parent_document.should == parent
        end

        it "sets the parent document on the embedded document when loaded from database" do
          reloaded.event.parent_document.should == reloaded
        end
      end

      context "on a collection" do
        it "sets the parent document on the collection" do
          parent.events.parent_document.should == parent
        end

        it "sets the parent document on each item added to a collection" do
          parent.events << special
          parent.events.first.parent_document.should == parent
        end

        it "sets the parent document on each item in a collection when loaded from database" do
          parent.events << special
          reloaded.events.first.parent_document.should == parent
        end
      end
    end
  end
end
