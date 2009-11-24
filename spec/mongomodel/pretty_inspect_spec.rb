require 'spec_helper'

module MongoModel
  describe EmbeddedDocument, '#inspect' do
    context "on base class" do
      it "should return class name" do
        MongoModel::EmbeddedDocument.inspect.should == 'MongoModel::EmbeddedDocument'
        MongoModel::Document.inspect.should == 'MongoModel::Document'
      end
    end
    
    context "on subclasses" do
      context "without properties" do
        define_class(:TestDocument, EmbeddedDocument)
      
        it "should return class name" do
          TestDocument.inspect.should == 'TestDocument()'
        end
      end
      
      context "with properties" do
        define_class(:TestDocument, EmbeddedDocument) do
          property :name, String
          property :age, Integer
        end
        
        it "should return class name and property definitions" do
          TestDocument.inspect.should == 'TestDocument(name: String, age: Integer)'
        end
      end
    end
    
    context "on subclass instances" do
      define_class(:TestDocument, Document) do
        property :name, String
        property :age, Integer
      end
      
      subject { TestDocument.new(:id => 'abc-123', :name => 'Doc name', :age => 54) }
  
      it "should return class name and property values" do
        subject.inspect.should == '#<TestDocument id: abc-123, name: "Doc name", age: 54>'
      end
    end
  end
end
