require 'spec_helper'

module MongoModel
  describe Document do
    describe "#timestamps!" do
      define_class(:TestDocument, Document) do
        timestamps!
      end
      
      it "should define a Time property updated_at" do
        TestDocument.properties.should include(:updated_at)
        TestDocument.properties[:updated_at].type.should == Time
      end
      
      it "should define a Time property created_at" do
        TestDocument.properties.should include(:created_at)
        TestDocument.properties[:created_at].type.should == Time
      end
    end
    
    context "with updated_at property" do
      define_class(:TestDocument, Document) do
        property :updated_at, Time
      end
      
      subject { TestDocument.new }
      
      before(:each) do
        @now = Time.now.utc
        Time.stub!(:now).and_return(@now)
      end
      
      it "should set the updated_at property to the current time when saved" do
        subject.save
        subject.updated_at.should == @now
      end
    end
    
    context "with updated_on property" do
      define_class(:TestDocument, Document) do
        property :updated_on, Date
      end
      
      subject { TestDocument.new }
      
      it "should set the updated_on property to the current date when saved" do
        subject.save
        subject.updated_on.should == Date.today
      end
    end
    
    context "with created_at column" do
      define_class(:TestDocument, Document) do
        property :created_at, Time
      end
      
      subject { TestDocument.new }
      
      before(:each) do
        @now = Time.now
        Time.stub!(:now).and_return(@now)
      end
      
      it "should set the created_at property to the current time when created" do
        subject.save
        subject.created_at.should == @now
      end
      
      it "should not change the created_at property when updated" do
        @now = Time.now.utc
        @next = 1.day.from_now.utc
        
        Time.stub!(:now).and_return(@now)
        
        subject.save
        
        Time.stub!(:now).and_return(@next)
        
        subject.save
        subject.created_at.should == @now
      end
    end
    
    context "with created_on property" do
      define_class(:TestDocument, Document) do
        property :created_on, Date
      end
      
      subject { TestDocument.new }
      
      it "should set the created_on property to the current date when created" do
        subject.save
        subject.created_on.should == Date.today
      end
      
      it "should not change the created_on property when updated" do
        subject.save
        
        @today = Date.today
        @tomorrow = 1.day.from_now
        
        Time.stub!(:now).and_return(@tomorrow)
        
        subject.save
        subject.created_on.should == @today
      end
    end
  end
end
