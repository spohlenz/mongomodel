require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    it "should use correct i18n scope" do
      described_class.i18n_scope.should == :mongomodel
    end
  end
end
