require 'spec_helper'
require 'active_support/time'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    describe "#timestamps!" do
      define_class(:TestDocument, described_class) do
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
      define_class(:TestDocument, described_class) do
        property :updated_at, Time
      end
      
      if specing?(EmbeddedDocument)
        define_class(:ParentDocument, Document) do
          property :child, TestDocument
        end
        
        let(:parent) { ParentDocument.new(:child => subject) }
        let(:doc) { parent }
      else
        let(:doc) { subject }
      end
      
      subject { TestDocument.new }
      
      before(:each) do
        @now = Types::Time.new.cast(Time.now)
        Time.stub!(:now).and_return(@now)
      end
      
      it "should set the updated_at property to the current time when saved" do
        doc.save
        subject.updated_at.should == @now
      end
    end
    
    context "with updated_on property" do
      define_class(:TestDocument, described_class) do
        property :updated_on, Date
      end
      
      if specing?(EmbeddedDocument)
        define_class(:ParentDocument, Document) do
          property :child, TestDocument
        end
        
        let(:parent) { ParentDocument.new(:child => subject) }
        let(:doc) { parent }
      else
        let(:doc) { subject }
      end
      
      subject { TestDocument.new }
      
      it "should set the updated_on property to the current date when saved" do
        doc.save
        subject.updated_on.should == Date.today
      end
    end
    
    context "with created_at property" do
      define_class(:TestDocument, described_class) do
        property :created_at, Time
      end
      
      if specing?(EmbeddedDocument)
        define_class(:ParentDocument, Document) do
          property :child, TestDocument
        end
        
        let(:parent) { ParentDocument.new(:child => subject) }
        let(:doc) { parent }
      else
        let(:doc) { subject }
      end
      
      subject { TestDocument.new }
      
      before(:each) do
        @now = Types::Time.new.cast(Time.now)
        Time.stub!(:now).and_return(@now)
      end
      
      it "should set the created_at property to the current time when created" do
        doc.save
        subject.created_at.should == @now
      end
      
      it "should not change the created_at property when updated" do
        @next = 1.day.from_now
        
        Time.stub!(:now).and_return(@now)
        
        doc.save
        
        Time.stub!(:now).and_return(@next)
        
        doc.save
        subject.created_at.should == @now
      end
      
      it "should preserve created_at attribute when set explicitly" do
        @a_year_ago = 1.year.ago
        
        subject.created_at = @a_year_ago
        doc.save
        
        subject.created_at.should == @a_year_ago
      end
    end
    
    context "with created_on property" do
      define_class(:TestDocument, described_class) do
        property :created_on, Date
      end
      
      if specing?(EmbeddedDocument)
        define_class(:ParentDocument, Document) do
          property :child, TestDocument
        end
        
        let(:parent) { ParentDocument.new(:child => subject) }
        let(:doc) { parent }
      else
        let(:doc) { subject }
      end
      
      subject { TestDocument.new }
      
      it "should set the created_on property to the current date when created" do
        doc.save
        subject.created_on.should == Date.today
      end
      
      it "should not change the created_on property when updated" do
        doc.save
        
        @today = Date.today
        @tomorrow = 1.day.from_now
        
        Time.stub!(:now).and_return(@tomorrow)
        
        doc.save
        subject.created_on.should == @today
      end
      
      it "should preserve created_on attribute when set explicitly" do
        @a_year_ago = 1.year.ago.to_date
        
        subject.created_on = @a_year_ago
        doc.save
        
        subject.created_on.should == @a_year_ago
      end
    end
  end
end
