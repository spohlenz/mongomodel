require 'spec_helper'

module MongoModel
  describe EmbeddedDocument do
    context "with no properties" do
      define_class(:EmptyDocument, EmbeddedDocument)
    
      it "should have an empty hash of properties" do
        EmptyDocument.properties.should == {}
      end
      
      it "should have an attributes store on the instance" do
        doc = EmptyDocument.new
        doc.attributes.should be_an_instance_of(MongoModel::Attributes::Store)
        doc.attributes.should == {}
      end
      
      it "should convert to mongo" do
        doc = EmptyDocument.new
        doc.to_mongo.should == {}
      end
    end
    
    context "with predefined properties" do
      define_class(:Person, EmbeddedDocument) do
        property :name, String
        property :age, Integer, :default => 21
      end
      
      define_class(:SkilledPerson, :Person) do
        property :skill, String
      end
      
      it "should be initializable with attributes hash" do
        doc = Person.new(:name => 'Fred', :age => 42)
        doc.attributes[:name].should == 'Fred'
        doc.attributes[:age].should == 42
      end
      
      it "should use default attributes when initializing with partial attributes hash" do
        doc = Person.new(:name => 'Maurice')
        doc.attributes[:age].should == 21
      end
      
      it "should have a populated hash of properties" do
        Person.properties.should == {
          :name => Properties::Property.new(:name, String),
          :age => Properties::Property.new(:age, Integer, :default => 21)
        }
      end
      
      it "should extend properties in subclasses" do
        SkilledPerson.properties.should == {
          :name => Properties::Property.new(:name, String),
          :age => Properties::Property.new(:age, Integer, :default => 21),
          :skill => Properties::Property.new(:skill, String)
        }
      end
      
      it "should have an attributes store on the instance" do
        doc = Person.new
        doc.attributes.should be_an_instance_of(MongoModel::Attributes::Store)
        doc.attributes.keys.should == [:name, :age]
      end
      
      it "should allow mass-assignment of attributes" do
        doc = Person.new
        doc.attributes = { :name => 'Mary' }
        doc.attributes[:name].should == 'Mary'
        doc.attributes[:age].should == 21
      end
      
      it "should convert to mongo representation" do
        doc = Person.new
        doc.to_mongo.should == { 'name' => nil, 'age' => 21 }
      end
      
      it "should load from mongo representation" do
        doc = Person.from_mongo({ 'name' => 'James', 'age' => 15 })
        doc.attributes[:name].should == 'James'
        doc.attributes[:age].should == 15
      end
    end
  end
end
