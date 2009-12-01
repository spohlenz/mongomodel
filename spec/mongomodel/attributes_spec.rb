require 'spec_helper'

module MongoModel
  describe Document do
    describe "setting date attributes" do
      define_class(:DatestampedDocument, Document) do
        property :datestamp, Date
      end
      
      before(:each) do
        @date = Date.today
      end
      
      subject { DatestampedDocument.create!(:datestamp => @date) }
      
      it "should read the correct date from attributes" do
        subject.datestamp.should == @date
      end
      
      it "should read the correct date after reloading" do
        DatestampedDocument.find(subject.id).datestamp.should == subject.datestamp
      end
    end
    
    describe "setting time attributes" do
      define_class(:TimestampedDocument, Document) do
        property :timestamp, Time
      end
      
      before(:each) do
        @time = Time.now
      end
      
      subject { TimestampedDocument.create!(:timestamp => @time) }
      
      it "should read the correct time from attributes" do
        subject.timestamp.should == @time
      end
      
      it "should read the correct time after reloading" do
        TimestampedDocument.find(subject.id).timestamp.should == subject.timestamp
      end
    end
  end
end
