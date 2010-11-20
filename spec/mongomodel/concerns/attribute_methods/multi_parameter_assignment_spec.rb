require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    define_class(:TestDocument, described_class) do
      property :timestamp, Time
      property :datestamp, Date
    end
    
    subject { TestDocument.new }
    
    describe "multiparameter assignment" do
      context "setting a timestamp" do
        it "should combine and assign parameters as Time" do
          subject.attributes = {
            "timestamp(1i)" => "2009",
            "timestamp(2i)" => "10",
            "timestamp(3i)" => "5",
            "timestamp(4i)" => "14",
            "timestamp(5i)" => "35"
          }
          
          subject.timestamp.should == Time.local(2009, 10, 5, 14, 35)
        end
      end
      
      context "setting a datestamp" do
        it "should combine and assign parameters as Date" do
          subject.attributes = {
            "datestamp(1i)" => "2008",
            "datestamp(2i)" => "4",
            "datestamp(3i)" => "9"
          }
          
          subject.datestamp.should == Date.new(2008, 4, 9)
        end
      end
    end
  end
end
