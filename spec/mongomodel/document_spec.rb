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
    
    describe "#find" do
      before(:each) do
        User.collection.save({ '_id' => '1', 'name' => 'Fred', :age => 45 })
        User.collection.save({ '_id' => '2', 'name' => 'Alistair', :age => 18 })
        User.collection.save({ '_id' => '3', 'name' => 'Barney', :age => 10 })
      end
      
      describe "by id" do
        context "document exists" do
          subject { User.find('2') }
          
          it "should return a User" do
            subject.should be_a(User)
          end
          
          it "should load the document attributes" do
            subject.attributes[:id].should == '2'
            subject.attributes[:name].should == 'Alistair'
          end
          
          it { should_not be_a_new_record }
          
          it "should stringify ids" do
            User.find(2).attributes[:id].should == '2'
          end
        end
        
        context "document does not exist" do
          it "should raise a DocumentNotFound exception" do
            lambda {
              User.find('4')
            }.should raise_error(MongoModel::DocumentNotFound)
          end
        end
        
        context "no id specified" do
          it "should raise an ArgumentError" do
            lambda { 
              User.find
            }.should raise_error(ArgumentError)
          end
        end
      end
      
      describe "by multiple ids" do
        context "all documents exist" do
          subject { User.find('1', '2') }
          
          it "should return an array of Users" do
            subject[0].should be_a(User)
            subject[1].should be_a(User)
          end
          
          it "should load document attributes" do
            subject[0].attributes[:name].should == 'Fred'
            subject[1].attributes[:name].should == 'Alistair'
          end
        end
        
        context "some documents missing" do
          it "should raise a DocumentNotFound exception" do
            lambda {
              User.find('1', '2', '4')
            }.should raise_error(MongoModel::DocumentNotFound)
          end
        end
      end
      
      describe "first" do
        context "documents exist" do
          subject { User.find(:first) }
          
          it "should return the first document" do
            subject.attributes[:id].should == '1'
            subject.attributes[:name].should == 'Fred'
          end
          
          it "should be aliased as #first" do
            User.first.should == subject
          end
        end
        
        context "no documents" do
          before(:each) { User.collection.remove }
          
          it "should return nil" do
            User.find(:first).should be_nil
          end
        end
      end
      
      describe "last" do
        context "documents exist" do
          subject { User.find(:last) }
          
          it "should return the last document" do
            subject.attributes[:id].should == '3'
            subject.attributes[:name].should == 'Barney'
          end
          
          it "should be aliased as #last" do
            User.last.should == subject
          end
        end
        
        context "no documents" do
          before(:each) { User.collection.remove }
          
          it "should return nil" do
            User.find(:last).should be_nil
          end
        end
      end
      
      describe "all" do
        subject { User.find(:all, :order => 'id ASC') }
        
        it "should return all documents as User instances" do
          subject.should have(3).users
          subject.each { |d| d.should be_a(User) }
        end
        
        it "should load attributes for each document" do
          subject[0].attributes[:name].should == 'Fred'
          subject[1].attributes[:name].should == 'Alistair'
          subject[2].attributes[:name].should == 'Barney'
        end
        
        it "should be aliased as #all" do
          User.all.should == subject
        end
        
        context "with exact-match conditions" do
          subject { User.find(:all, :conditions => { :name => 'Alistair' }) }
          
          it "should only return documents matching conditions" do
            subject.should have(1).user
            subject[0].attributes[:name].should == 'Alistair'
          end
        end
        
        context "with inequality conditions" do
          subject { User.find(:all, :conditions => { :age.lt => 21 }) }
          
          it "should only return documents matching conditions" do
            subject.should have(2).users
            subject[0].attributes[:name].should == 'Alistair'
            subject[1].attributes[:name].should == 'Barney'
          end
        end
      end
    end
  end
end
