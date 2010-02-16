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
    
    it "should have a populated hash of properties" do
      Person.properties.should include({
        :name => Properties::Property.new(:name, String),
        :age => Properties::Property.new(:age, Integer, :default => 21)
      })
    end
    
    it "should extend properties in subclasses" do
      SkilledPerson.properties.should include({
        :name => Properties::Property.new(:name, String),
        :age => Properties::Property.new(:age, Integer, :default => 21),
        :skill => Properties::Property.new(:skill, String)
      })
    end
    
    it "should have a set of internal property names" do
      Person.internal_properties.should include(Person.properties[:type])
      Person.internal_properties.should include(Person.properties[:id]) if described_class == Document
    end
  end
end
