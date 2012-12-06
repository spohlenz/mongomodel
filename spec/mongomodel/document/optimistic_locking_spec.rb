require 'spec_helper'

module MongoModel
  specs_for(Document) do
    describe "optimistic locking" do
      define_class(:TestDocument, Document)
      
      it "does not lock optimistically by default" do
        TestDocument.locking_enabled?.should be_false
      end
      
      it "does not include a lock version property" do
        TestDocument.properties.should_not include(:_lock_version)
      end
      
      context "with locking enabled" do
        define_class(:TestDocument, Document) do
          property :name, String
          self.lock_optimistically = true
        end
        
        before(:each) do
          @fresh = TestDocument.create!(:name => 'Original')
          @stale = @fresh.dup
          
          @fresh.name = 'Changed'
          @fresh.save!
        end
        
        it "is enabled" do
          TestDocument.locking_enabled?.should be_true
        end
        
        it "defines a lock version property" do
          TestDocument.properties.should include(:_lock_version)
        end
        
        it "saves a fresh document" do
          @fresh.save.should be_true
        end
        
        it "saves! a fresh document" do
          @fresh.save!.should be_true
        end
        
        it "does not save a stale document" do
          @stale.save.should be_false
          @stale._lock_version.should == 1
        end
        
        it "raises an error when trying to save! a stale document" do
          lambda { @stale.save! }.should raise_error(DocumentNotSaved)
        end
      end
    end
  end
end
