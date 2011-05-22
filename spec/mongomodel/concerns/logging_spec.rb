require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    describe "logging" do
      define_class(:TestDocument, described_class)
      
      let(:logger) { mock('logger').as_null_object }
      before(:all) { MongoModel.logger = logger }
      
      it "should have a logger reader on the class" do
        TestDocument.logger.should == logger
      end
      
      it "should have a logger reader on the instance" do
        TestDocument.new.logger.should == logger
      end
    end
  end
end
