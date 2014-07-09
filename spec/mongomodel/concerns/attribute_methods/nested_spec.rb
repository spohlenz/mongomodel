require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    def self.define_user(type)
      define_class(:User, type) do
        property :name, String
        property :age, Integer
      end
    end
    
    describe ".accepts_nested_attributes_for" do
      describe "single embedded property" do
        define_user(EmbeddedDocument)
        define_class(:Account, described_class) do
          property :owner, User
          accepts_nested_attributes_for :owner
        end
        
        subject { Account.new }
        
        it "creates new model when property is blank" do
          subject.owner_attributes = { :name => "John Smith", :age => 35 }
          subject.owner.name.should == "John Smith"
          subject.owner.age.should == 35
        end
        
        it "sets existing model attributes when property exists" do
          subject.owner = User.new(:name => "Jane Doe")
          subject.owner_attributes = { :age => 22 }
          subject.owner.name.should == "Jane Doe"
          subject.owner.age.should == 22
        end
      end
      
      describe "embedded collection" do
        define_user(EmbeddedDocument)
        define_class(:Account, described_class) do
          property :owners, Collection[User]
          accepts_nested_attributes_for :owners
        end
        
        subject { Account.new }
        
        it "accepts an array of hashes" do
          subject.owners_attributes = [
            { :name => "Fred", :age => 35 },
            { :name => "Mary", :age => 22 }
          ]
          
          subject.owners[0].name.should == "Fred"
          subject.owners[0].age.should == 35
          subject.owners[1].name.should == "Mary"
          subject.owners[1].age.should == 22
        end
        
        it "accepts a hash keyed by indexes" do
          subject.owners_attributes = {
            "1" => { :name => "Joe", :age => 15 },
            "0" => { :name => "Peter", :age => 44 }
          }
          
          subject.owners[0].name.should == "Peter"
          subject.owners[0].age.should == 44
          subject.owners[1].name.should == "Joe"
          subject.owners[1].age.should == 15
        end
        
        it "modifies existing collection" do
          subject.owners << User.new(:name => "John")
          subject.owners_attributes = [
            { :age => 18 },
            { :name => "Max", :age => 10 }
          ]
          
          subject.owners[0].name.should == "John"
          subject.owners[0].age.should == 18
          subject.owners[1].name.should == "Max"
          subject.owners[1].age.should == 10
        end
      end
      
      describe "embedded collection with limit" do
        define_user(EmbeddedDocument)
        define_class(:Account, described_class) do
          property :owners, Collection[User]
          accepts_nested_attributes_for :owners, :limit => 2
        end
        
        subject { Account.new }
        
        it "raises a TooManyDocuments error if number of documents exceeds limit" do
          lambda {
            subject.owners_attributes = [{}, {}, {}]
          }.should raise_error(MongoModel::TooManyDocuments, "Maximum 2 documents are allowed. Got 3 documents instead.")
        end
      end
      
      describe "embedded collection with :clear => true" do
        define_user(EmbeddedDocument)
        define_class(:Account, described_class) do
          property :owners, Collection[User]
          accepts_nested_attributes_for :owners, :clear => true
        end
        
        subject { Account.new(:owners => [User.new, User.new]) }
        
        it "clears the collection first when assigning attributes" do
          subject.owners_attributes = [{ :age => 18 }]
          subject.owners.size.should == 1
        end
      end
      
      describe "belongs_to association" do
        define_user(Document)
        define_class(:Account, described_class) do
          belongs_to :owner, :class => User
          accepts_nested_attributes_for :owner
        end

        subject { Account.new }

        it "creates new model when property is blank" do
          subject.owner_attributes = { :name => "John Smith", :age => 35 }
          subject.owner.name.should == "John Smith"
          subject.owner.age.should == 35
        end

        it "sets existing model attributes when property exists" do
          subject.owner = User.new(:name => "Jane Doe")
          subject.owner_attributes = { :age => 22 }
          subject.owner.name.should == "Jane Doe"
          subject.owner.age.should == 22
        end
      end
    end
  end
  
  specs_for(Document) do
    define_class(:User, Document) do
      property :name, String
      property :age, Integer
    end
    
    describe ".accepts_nested_attributes_for" do
      describe "has_many association" do
        define_class(:Account, described_class) do
          has_many :owners, :class => User
          accepts_nested_attributes_for :owners
        end
        
        subject { Account.new }
        
        it "accepts an array of hashes" do
          subject.owners_attributes = [
            { :name => "Fred", :age => 35 },
            { :name => "Mary", :age => 22 }
          ]
          
          subject.owners[0].name.should == "Fred"
          subject.owners[0].age.should == 35
          subject.owners[1].name.should == "Mary"
          subject.owners[1].age.should == 22
        end
        
        it "accepts a hash keyed by indexes" do
          subject.owners_attributes = {
            "1" => { :name => "Joe", :age => 15 },
            "0" => { :name => "Peter", :age => 44 }
          }
          
          subject.owners[0].name.should == "Peter"
          subject.owners[0].age.should == 44
          subject.owners[1].name.should == "Joe"
          subject.owners[1].age.should == 15
        end
      end
      
      describe "has_many association with limit" do
        define_class(:Account, described_class) do
          has_many :owners, :class => User
          accepts_nested_attributes_for :owners, :limit => 2
        end
        
        subject { Account.new }
        
        it "raises a TooManyDocuments error if number of documents exceeds limit" do
          lambda {
            subject.owners_attributes = [{}, {}, {}]
          }.should raise_error(MongoModel::TooManyDocuments, "Maximum 2 documents are allowed. Got 3 documents instead.")
        end
      end
      
      describe "has_many association with :clear => true" do
        define_class(:Account, described_class) do
          has_many :owners, :class => User
          accepts_nested_attributes_for :owners, :clear => true
        end
        
        subject { Account.new(:owners => [User.new, User.new]) }

        it "clears the collection first when assigning attributes" do
          subject.owners_attributes = [{ :age => 18 }]
          subject.owners.size.should == 1
        end
      end
    end
  end
end
