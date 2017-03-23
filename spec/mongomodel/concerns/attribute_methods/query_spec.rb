require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    define_class(:TestDocument, described_class) do
      property :foo, String
      property :boolean, Boolean
    end

    subject { TestDocument.new }

    describe "#query_attribute" do
      context "string attribute" do
        it "returns true if the attribute is not blank" do
          subject.foo = 'set foo'
          subject.query_attribute(:foo).should be true
          subject.foo?.should be true
        end

        it "returns false if the attribute is nil" do
          subject.foo = nil
          subject.query_attribute(:foo).should be false
          subject.foo?.should be false
        end

        it "returns false if the attribute is blank" do
          subject.foo = ''
          subject.query_attribute(:foo).should be false
          subject.foo?.should be false
        end
      end

      context "boolean attribute" do
        it "returns true if the attribute is true" do
          subject.boolean = true
          subject.query_attribute(:boolean).should be true
          subject.boolean?.should be true
        end

        it "returns false if the attribute is nil" do
          subject.boolean = nil
          subject.query_attribute(:boolean).should be false
          subject.boolean?.should be false
        end

        it "returns false if the attribute is false" do
          subject.boolean = false
          subject.query_attribute(:boolean).should be false
          subject.boolean?.should be false
        end
      end
    end
  end
end
