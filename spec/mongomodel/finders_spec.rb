require 'spec_helper'

module MongoModel
  describe Document do
    define_class(:User, Document) do
      property :name, String
      property :age, Integer
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
  
  describe FinderOperator do
    subject { FinderOperator.new(:age, :gt) }
    
    it "should convert to mongo conditions" do
      subject.to_mongo_conditions(14).should == { '$gt' => 14 }
    end
    
    it "should be equal to a FinderOperator with the same field and operator" do
      subject.should == FinderOperator.new(:age, :gt)
    end
    
    it "should not be equal to a FinderOperator with a different field/operator" do
      subject.should_not == FinderOperator.new(:age, :lte)
      subject.should_not == FinderOperator.new(:date, :gt)
    end
    
    it "should be created from symbol methods" do
      :age.gt.should == FinderOperator.new(:age, :gt)
      :date.lte.should == FinderOperator.new(:date, :lte)
    end
    
    it "should be equal within a hash" do
      { :age.gt => 10 }.should == { :age.gt => 10 }
    end
  end
end
