require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    describe "logging" do
      define_class(:TestDocument, described_class)

      let(:logger) { double('logger').as_null_object }

      before(:each) { MongoModel.logger = logger }
      after(:each) { MongoModel.logger = nil }

      it "has a logger reader on the class" do
        TestDocument.logger.should == logger
      end

      it "has a logger reader on the instance" do
        TestDocument.new.logger.should == logger
      end
    end
  end
end
