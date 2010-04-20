require 'spec_helper'

module MongoModel
  describe Document do
    describe "persistence" do
      define_class(:User, Document) do
        property :name, String
        property :age, Integer
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
            doc['_id'].to_s.should == subject.attributes[:id]
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
      
      describe "#collection_name" do
        it "should infer the default collection name" do
          User.collection_name.should == 'users'
        end

        it "should infer the default collection name for namespaced models" do
          module ::Blog
            class Post < MongoModel::Document; end
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
      
      describe "#create" do
        context "attributes hash" do
          it "should pass attributes to instance" do
            @user = User.create(:name => 'Test', :age => 18)
            @user.name.should == 'Test'
            @user.age.should == 18
          end

          it "should save the instance" do
            User.create.should_not be_a_new_record
          end

          it "should yield the instance to a given block before saving" do
            block_called = false

            User.create do |u|
              block_called = true

              u.should be_an_instance_of(User)
              u.should be_a_new_record
            end

            block_called.should be_true
          end
        end

        context "array of attribute hashes" do
          def create_users(&block)
            User.create([{ :name => 'Test', :age => 18 }, { :name => 'Second', :age => 21 }], &block)
          end

          it "should return instances in array with associated attributes" do
            @users = create_users
            @users[0].name.should == 'Test'
            @users[0].age.should == 18
            @users[1].name.should == 'Second'
            @users[1].age.should == 21
          end

          it "should save each instance" do
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
        end
      end
      
      describe "#delete (class method)" do
        before(:each) do
          User.create(:id => 'user-1', :name => 'Test', :age => 10)
          User.create(:id => 'user-2', :name => 'Another', :age => 20)
          User.create(:id => 'user-3')
        end

        it "should delete by id" do
          User.delete('user-1')

          User.exists?('user-1').should be_false
          User.exists?('user-2').should be_true
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
          @user = User.create(:id => 'user-1')
          User.create(:id => 'user-2', :name => 'Another')
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
        
        it "should mark the instance as destroyed" do
          @user.delete
          @user.should be_destroyed
        end
      end

      describe "#destroy (instance method)" do
        before(:each) do
          @user = User.create(:id => 'user-1')
          User.create(:id => 'user-2', :name => 'Another')
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
        
        it "should mark the instance as destroyed" do
          @user.destroy
          @user.should be_destroyed
        end
      end

      describe "#destroy (class method)" do
        before(:each) do
          User.create(:id => 'user-1', :name => 'Test', :age => 10)
          User.create(:id => 'user-2', :name => 'Another', :age => 20)
          User.create(:id => 'user-3')
        end

        it "should destroy by id" do
          User.destroy('user-1')

          User.exists?('user-1').should be_false
          User.exists?('user-2').should be_true
        end

        it "should destroy by multiple ids in array" do
          User.destroy(['user-1', 'user-2'])

          User.exists?('user-1').should be_false
          User.exists?('user-2').should be_false
          User.exists?('user-3').should be_true
        end
      end
      
      describe "#update_attributes" do
        let(:user) { User.new(:name => 'Original', :age => 10) }
        
        before(:each) { user.update_attributes(:name => 'Changed', :age => 20) }
        
        it "should update the attributes" do
          user.name.should == 'Changed'
          user.age.should == 20
        end
        
        it "should save the document" do
          user.should_not be_a_new_record
        end
      end
      
      describe "#update_attribute" do
        let(:user) { User.new(:name => 'Original', :age => 10) }
        
        before(:each) { user.update_attribute(:name, 'Changed') }
        
        it "should update the given attribute" do
          user.name.should == 'Changed'
        end
        
        it "should save the document" do
          user.should_not be_a_new_record
        end
      end
    end
  end
end
