require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    define_class(:TestDocument, described_class) do
      property :foo, Date
    end

    subject { TestDocument.new }

    describe "#read_attribute_before_type_cast" do
      context "with property" do
        it "returns the attribute before type casting" do
          subject.attributes[:foo] = 'some date'
          subject.read_attribute_before_type_cast(:foo).should == 'some date'
        end

        it "defines a reader method" do
          subject.attributes[:foo] = 'some date'
          subject.foo_before_type_cast.should == 'some date'
        end
      end

      context "no property" do
        it "returns the attribute without type casting" do
          subject.attributes[:bar] = 'set bar'
          subject.read_attribute_before_type_cast(:bar).should == 'set bar'
        end

        it "does not define a reader method" do
          lambda { subject.bar_before_type_cast }.should raise_error(NoMethodError)
        end
      end
    end

    describe "#attributes_before_type_cast" do
      it "returns a hash of attributes before type casting" do
        subject.attributes[:foo] = 'some date'
        subject.attributes[:bar] = 'set bar'

        subject.attributes_before_type_cast[:foo].should == 'some date'
        subject.attributes_before_type_cast[:bar].should == 'set bar'
      end
    end
  end
end
