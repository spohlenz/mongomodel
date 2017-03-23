require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    define_class(:Person, described_class) do
      property :name, String
      property :age, Integer, :default => 21
    end

    define_class(:SkilledPerson, :Person) do
      property :skill, String
    end

    it "has a populated hash of properties" do
      Person.properties.should include({
        :name => Properties::Property.new(:name, String),
        :age => Properties::Property.new(:age, Integer, :default => 21)
      })
    end

    it "extends properties in subclasses" do
      SkilledPerson.properties.should include({
        :name => Properties::Property.new(:name, String),
        :age => Properties::Property.new(:age, Integer, :default => 21),
        :skill => Properties::Property.new(:skill, String)
      })
    end

    it "has a set of internal property names" do
      Person.internal_properties.should include(Person.properties[:type])
      Person.internal_properties.should include(Person.properties[:id]) if described_class == Document
    end

    describe "when used as a property inside a document" do
      define_class(:Factory, Document) do
        property :manager, Person
      end

      let(:person) { SkilledPerson.new(:name => "Joe", :age => 44, :skill => "Management") }
      let(:with_manager) { Factory.create!(:manager => person) }
      let(:without_manager) { Factory.create! }

      it "loads correctly when property is set" do
        factory = Factory.find(with_manager.id)
        factory.manager.should be_an_instance_of(SkilledPerson)
        factory.manager.name.should == "Joe"
        factory.manager.skill.should == "Management"
      end

      it "loads correctly when property is nil" do
        factory = Factory.find(without_manager.id)
        factory.manager.should be_nil
      end
    end

    describe "when using a property type that defines #mongomodel_accessors" do
      define_class(:ParentClass, described_class) do
        property :custom, CustomClassWithAccessors
      end

      subject { ParentClass.new }

      it "includes methods from the module" do
        subject.should respond_to(:custom_accessor)
        subject.custom_accessor.should == "Custom accessor method"
      end
    end
  end
end
