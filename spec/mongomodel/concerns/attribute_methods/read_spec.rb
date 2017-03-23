require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    define_class(:TestDocument, described_class) do
      property :foo, String
    end

    subject { TestDocument.new(:foo => 'value of foo', :bar => 'value of bar') }

    describe "#read_attribute" do
      context "valid property" do
        it "returns the attribute value" do
          subject.read_attribute(:foo).should == 'value of foo'
        end

        it "defines a reader method" do
          subject.foo.should == 'value of foo'
        end
      end

      context "no property" do
        it "returns the attribute value" do
          subject.read_attribute(:bar).should == 'value of bar'
        end

        it "does not define a reader method" do
          lambda { subject.bar }.should raise_error(NoMethodError)
        end
      end
    end

    describe "#[]" do
      it "reads the given attribute" do
        subject.should_receive(:read_attribute).with(:foo).and_return('value of foo')
        subject[:foo].should == 'value of foo'
      end
    end
  end

  specs_for(Document) do
    define_class(:TestDocument, Document)

    subject { TestDocument.new }

    describe "#id" do
      it "returns id from attributes" do
        subject.id.should == subject.attributes[:id]
      end
    end
  end
end
