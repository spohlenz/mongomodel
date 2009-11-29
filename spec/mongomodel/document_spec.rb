require 'spec_helper'

module MongoModel
  describe Document do
    define_class(:User, Document) do
      property :name, String
      property :age, Integer
    end
    
    it "should inherit from EmbeddedDocument" do
      Document.ancestors.should include(EmbeddedDocument)
    end
    
    it "should have an id property" do
      property = Document.properties[:id]
      property.name.should == :id
      property.as.should == '_id'
      property.default(mock('instance')).should_not be_nil
    end
    
    describe "#collection_name" do
      it "should infer the default collection name" do
        User.collection_name.should == 'users'
      end
  
      it "should infer the default collection name for namespaced models" do
        module ::Blog
          class Post < Document; end
        end
    
        ::Blog::Post.collection_name.should == 'blog.posts'
      end
  
      it "should allow a custom collection name" do
        class ::CustomCollectionName < Document
          self.collection_name = 'foobar'
        end
    
        ::CustomCollectionName.collection_name.should == 'foobar'
      end
  
      it "should inherit a custom collection name" do
        class ::CustomCollectionName < Document
          self.collection_name = 'foobar'
        end
        class ::CustomCollectionNameSubclass < ::CustomCollectionName; end
    
        ::CustomCollectionNameSubclass.collection_name.should == 'foobar'
      end
    end
    
    describe "#collection" do
      it "should be a mongo collection" do
        User.collection.should be_a(Mongo::Collection)
      end
      
      it "should use the correct collection name" do
        User.collection.name.should == 'users'
      end
    end
    
    describe "#database" do
      it "should return the current database" do
        User.database.should == MongoModel.database
      end
    end
    
    context "an unsaved instance" do
      subject { User.new(:name => 'Test') }
      
      it { should be_a_new_record }
      
      describe "#save" do
        it "should return true" do
          subject.save.should == true
        end
        
        it "should persist the document to the collection" do
          subject.save
          
          doc = User.collection.find_one
          doc['_id'].should == subject.attributes[:id]
          doc['name'].should == 'Test'
        end
      end
      
      context "with a custom id" do
        subject { User.new(:id => 'custom-id') }
        
        it "should save the document using the custom id" do
          subject.save
          User.collection.find_one['_id'].should == 'custom-id'
        end
      end
    end
    
    context "a saved instance" do
      subject { User.new(:name => 'Test') }
      
      before(:each) { subject.save }
      
      it { should_not be_a_new_record }
      
      describe "#save" do
        it "should return true" do
          subject.save.should == true
        end
        
        it "should not create a new document" do
          lambda {
            subject.save
          }.should_not change(User.collection, :count)
        end
        
        it "should update the document attributes" do
          subject.attributes[:name] = 'Changed'
          subject.save
          
          doc = User.collection.find_one
          doc['name'].should == 'Changed'
        end
      end
    end
    
    context "a frozen instance" do
      subject { User.new(:name => 'Test') }
      
      before(:each) { subject.freeze }
      
      it { should be_frozen }
      
      it "should not allow changes to the attributes hash" do
        lambda { subject.attributes[:name] = 'Change' }.should raise_error
      end
    end
    
    describe "#delete (class method)" do
      before(:each) do
        create_instances(1, User, :id => 'user-1', :name => 'Test', :age => 10)
        create_instances(1, User, :id => 'user-2', :name => 'Another', :age => 20)
        create_instances(1, User, :id => 'user-3')
      end
      
      it "should delete by id" do
        User.delete('user-1')
        
        User.exists?('user-1').should be_false
        User.exists?('user-2').should be_true
      end
      
      it "should delete by conditions" do
        User.delete(:age.gt => 15)
        
        User.exists?('user-2').should be_false
        User.exists?('user-1').should be_true
      end
      
      it "should delete by multiple ids in array" do
        User.delete(['user-1', 'user-2'])
        
        User.exists?('user-1').should be_false
        User.exists?('user-2').should be_false
        User.exists?('user-3').should be_true
      end
    end
    
    describe "#delete (instance method)" do
      before(:each) do
        @user = User.new(:id => 'user-1')
        @user.save
        
        create_instances(1, User, :id => 'user-2', :name => 'Another')
      end
      
      it "should delete the instance from the database" do
        @user.delete
        
        User.exists?('user-1').should be_false
        User.exists?('user-2').should be_true
      end
      
      it "should return the instance" do
        @user.delete.should == @user
      end
      
      it "should freeze the instance" do
        @user.delete
        @user.should be_frozen
      end
    end
    
    describe "#destroy (instance method)" do
      before(:each) do
        @user = User.new(:id => 'user-1')
        @user.save
        
        create_instances(1, User, :id => 'user-2', :name => 'Another')
      end
      
      it "should delete the instance from the database" do
        @user.destroy
        
        User.exists?('user-1').should be_false
        User.exists?('user-2').should be_true
      end
      
      it "should return the instance" do
        @user.destroy.should == @user
      end
      
      it "should freeze the instance" do
        @user.destroy
        @user.should be_frozen
      end
    end
    
    describe "#destroy (class method)" do
      before(:each) do
        create_instances(1, User, :id => 'user-1', :name => 'Test', :age => 10)
        create_instances(1, User, :id => 'user-2', :name => 'Another', :age => 20)
        create_instances(1, User, :id => 'user-3')
      end
      
      it "should destroy by id" do
        User.destroy('user-1')
        
        User.exists?('user-1').should be_false
        User.exists?('user-2').should be_true
      end
      
      it "should destroy by conditions" do
        User.destroy(:age.gt => 15)
        
        User.exists?('user-2').should be_false
        User.exists?('user-1').should be_true
      end
      
      it "should destroy by multiple ids in array" do
        User.destroy(['user-1', 'user-2'])
        
        User.exists?('user-1').should be_false
        User.exists?('user-2').should be_false
        User.exists?('user-3').should be_true
      end
    end
  end
end
