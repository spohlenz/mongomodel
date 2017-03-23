require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    describe "#inspect" do
      context "on base class" do
        it "returns class name" do
          described_class.inspect.should == described_class.name
        end
      end

      context "on subclasses" do
        context "without properties" do
          define_class(:TestDocument, described_class)

          it "returns class name" do
            TestDocument.inspect.should == 'TestDocument()'
          end
        end

        context "with properties" do
          define_class(:TestDocument, described_class) do
            property :name, String
            property :age, Integer
          end

          it "returns class name and property definitions" do
            TestDocument.inspect.should == 'TestDocument(name: String, age: Integer)'
          end
        end
      end
    end
  end

  specs_for(Document) do
    describe "#inspect" do
      context "on subclass instances" do
        define_class(:TestDocument, Document) do
          property :name, String
          property :age, Integer
        end

        subject { TestDocument.new(:id => 'abc-123', :name => 'Doc name', :age => 54) }

        it "returns class name and property values" do
          subject.inspect.should == '#<TestDocument id: abc-123, name: "Doc name", age: 54>'
        end
      end
    end
  end

  specs_for(EmbeddedDocument) do
    describe "#inspect" do
      context "on subclass instances" do
        define_class(:TestDocument, EmbeddedDocument) do
          property :name, String
          property :age, Integer
        end

        subject { TestDocument.new(:name => 'Doc name', :age => 54) }

        it "returns class name and property values" do
          subject.inspect.should == '#<TestDocument name: "Doc name", age: 54>'
        end
      end
    end
  end
end
