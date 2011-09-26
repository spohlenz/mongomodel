require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    define_class(:TestDocument, described_class) do
      property :timestamp, Time
      property :datestamp, Date
      property :datetime,  DateTime
    end
    
    subject { TestDocument.new }
    
    describe "multiparameter assignment from select" do
      context "setting a Time" do
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
      
      context "setting a Date" do
        it "should combine and assign parameters as Date" do
          subject.attributes = {
            "datestamp(1i)" => "2008",
            "datestamp(2i)" => "4",
            "datestamp(3i)" => "9"
          }
          
          subject.datestamp.should == Date.new(2008, 4, 9)
        end
      end
      
      context "setting a DateTime" do
        it "should combine and assign parameters as DateTime" do
          subject.attributes = {
            "datetime(1i)" => "2009",
            "datetime(2i)" => "10",
            "datetime(3i)" => "5",
            "datetime(4i)" => "14",
            "datetime(5i)" => "35"
          }
          
          subject.datetime.should == DateTime.civil(2009, 10, 5, 14, 35)
        end
      end
    end
  end
end
