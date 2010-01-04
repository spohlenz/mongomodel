require 'spec_helper'

module MongoModel
  describe Document do
    define_class(:User, Document) do
      property :name, String
      property :age, Integer
    end
    
    define_class(:NonUser, Document)
    
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
            subject.id.should == '2'
            subject.name.should == 'Alistair'
          end
          
          it { should_not be_a_new_record }
          
          it "should stringify ids" do
            User.find(2).id.should == '2'
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
            subject[0].name.should == 'Fred'
            subject[1].name.should == 'Alistair'
          end
          
          it "should load documents in correct order" do
            result = User.find('2', '1')
            result[0].id.should == '2'
            result[1].id.should == '1'
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
            subject.id.should == '1'
            subject.name.should == 'Fred'
          end
          
          it "should be aliased as #first" do
            User.first.should == subject
          end
          
          context "with order" do
            it "should find first document by order" do
              User.find(:first, :order => :name.asc).name.should == 'Alistair'
            end
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
          
          it "should return the last document (by id)" do
            subject.id.should == '3'
            subject.name.should == 'Barney'
          end
          
          it "should be aliased as #last" do
            User.last.should == subject
          end
          
          context "with order" do
            it "should find last document by order" do
              User.find(:last, :order => :name.asc).name.should == 'Fred'
            end
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
          subject[0].name.should == 'Fred'
          subject[1].name.should == 'Alistair'
          subject[2].name.should == 'Barney'
        end
        
        it "should be aliased as #all" do
          User.all.should == subject
        end
        
        context "with exact-match conditions" do
          subject { User.find(:all, :conditions => { :name => 'Alistair' }) }
          
          it "should only return documents matching conditions" do
            subject.should have(1).user
            subject[0].name.should == 'Alistair'
          end
        end
        
        context "with inequality conditions" do
          subject { User.find(:all, :conditions => { :age.lt => 21 }) }
          
          it "should only return documents matching conditions" do
            subject.should have(2).users
            subject[0].name.should == 'Alistair'
            subject[1].name.should == 'Barney'
          end
        end
      end
    end
    
    describe "#count" do
      before(:each) do
        5.times { User.create(:age => 18) }
        7.times { User.create(:age => 42) }
        3.times { NonUser.create }
      end
      
      context "without arguments" do
        it "should return the count for that particular model" do
          User.count.should == 12
          NonUser.count.should == 3
        end
      end
      
      context "with conditions" do
        it "should return the count for the model that match the conditions" do
          User.count(:age => 18).should == 5
          User.count(:age.gte => 18).should == 12
        end
      end
    end
    
    describe "#exists?" do
      before(:each) do
        User.create(:id => 'user-1', :name => 'Test', :age => 10)
      end
      
      context "by id" do
        it "should return true if the document exists" do
          User.exists?('user-1').should == true
        end
        
        it "should return false if the document does not exist" do
          User.exists?('user-2').should == false
        end
      end
      
      context "by conditions" do
        it "should return true if the document exists" do
          User.exists?(:name => 'Test').should == true
        end
        
        it "should return false if the document does not exist" do
          User.exists?(:name => 'Nonexistant').should == false
        end
      end
    end
  end
end
