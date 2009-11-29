require 'spec_helper'

module MongoModel
  describe Document do
    define_class(:TestDocument, Document) do
      property :title, String
      validates_presence_of :title
    end
    
    context "when invalid" do
      subject { TestDocument.new }
      
      context "#save" do
        it "should return false" do
          subject.save.should be_false
        end
      end
      
      context "#save!" do
        before(:each) do
          subject.errors.stub!(:full_messages).and_return(["first error", "second error"])
        end
        
        it "should raise a MongoModel::DocumentInvalid exception" do
          lambda { subject.save! }.should raise_error(MongoModel::DocumentInvalid, "Validation failed: first error, second error")
        end
      end
    end
    
    describe "validation on create" do
      define_class(:TestDocument, Document) do
        property :title, String
        validates_presence_of :title, :on => :create
      end
      
      subject { TestDocument.new }
      
      context "new document" do
        it { should_not be_valid }
      end
      
      context "existing document" do
        before(:each) do
          subject.title = 'A title'
          subject.save
          
          subject.title = nil
        end
        
        it { should be_valid }
      end
    end
    
    describe "validation on update" do
      define_class(:TestDocument, Document) do
        property :title, String
        validates_presence_of :title, :on => :update
      end
      
      subject { TestDocument.new }
      
      context "new document" do
        it { should be_valid }
      end
      
      context "existing document" do
        before(:each) do
          subject.title = 'A title'
          subject.save
          
          subject.title = nil
        end
        
        it { should_not be_valid }
      end
    end
    
    describe "#errors" do
      subject { TestDocument.new.errors }
      it { should be_an_instance_of(ActiveModel::Errors) }
    end
    
    describe "skipping validation when saving" do
      subject { TestDocument.new }
      
      it "should not validate the document" do
        subject.should_not_receive(:valid?)
        subject.save(false)
      end
      
      it "should save the document" do
        subject.should_receive(:save_without_validation).and_return(true)
        subject.save(false)
      end
      
      it "should return true" do
        subject.save(false).should be_true
      end
    end
    
    describe "#create" do
      define_class(:User, Document) do
        property :name, String
        property :age, Integer
        
        validates_presence_of :name
      end
      
      context "attributes hash" do
        it "should pass attributes to instance" do
          @user = User.create!(:name => 'Test', :age => 18)
          @user.name.should == 'Test'
          @user.age.should == 18
        end
      
        it "should save! the instance" do
          User.create!(:name => 'Test').should_not be_a_new_record
        end
      
        it "should yield the instance to a given block before saving" do
          block_called = false
          
          User.create!(:name => 'Test') do |u|
            block_called = true
            
            u.should be_an_instance_of(User)
            u.should be_a_new_record
          end
          
          block_called.should be_true
        end
        
        it "should raise an exception if the document is invalid" do
          lambda { User.create! }.should raise_error(DocumentInvalid)
        end
      end
      
      context "array of attribute hashes" do
        def create_users(&block)
          User.create!([{ :name => 'Test', :age => 18 }, { :name => 'Second', :age => 21 }], &block)
        end
        
        it "should return instances in array with associated attributes" do
          @users = create_users
          @users[0].name.should == 'Test'
          @users[0].age.should == 18
          @users[1].name.should == 'Second'
          @users[1].age.should == 21
        end
        
        it "should save! each instance" do
          create_users.each { |user| user.should_not be_a_new_record }
        end
        
        it "should yield each instance to a given block before saving" do
          block_called = 0
          
          create_users do |u|
            block_called += 1
            
            u.should be_an_instance_of(User)
            u.should be_a_new_record
          end
          
          block_called.should == 2
        end
        
        it "should raise an exception if a document is invalid" do
          lambda { User.create!([ {}, {} ]) }.should raise_error(DocumentInvalid)
        end
      end
    end
  end
end
