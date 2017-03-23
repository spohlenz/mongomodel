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
          it "returns true" do
            subject.save.should == true
          end

          it "persists the document to the collection" do
            subject.save

            doc = User.collection.find_one
            doc['_id'].to_s.should == subject.attributes[:id].to_s
            doc['name'].should == 'Test'
          end
        end

        context "with a custom id" do
          subject { User.new(:id => 'custom-id') }

          it "saves the document using the custom id" do
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
          it "returns true" do
            subject.save.should == true
          end

          it "does not create a new document" do
            lambda {
              subject.save
            }.should_not change(User.collection, :count)
          end

          it "updates the document attributes" do
            subject.attributes[:name] = 'Changed'
            subject.save

            doc = User.collection.find_one
            doc['name'].should == 'Changed'
          end
        end
      end

      describe "#collection_name" do
        it "infers the default collection name" do
          User.collection_name.should == 'users'
        end

        it "infers the default collection name for namespaced models" do
          module ::Blog
            class Post < MongoModel::Document; end
          end

          ::Blog::Post.collection_name.should == 'blog.posts'
        end

        it "allows a custom collection name" do
          class ::CustomCollectionName < Document
            self.collection_name = 'foobar'
          end

          ::CustomCollectionName.collection_name.should == 'foobar'
        end

        it "inherits a custom collection name" do
          class ::CustomCollectionName < Document
            self.collection_name = 'foobar'
          end
          class ::CustomCollectionNameSubclass < ::CustomCollectionName; end

          ::CustomCollectionNameSubclass.collection_name.should == 'foobar'
        end

        it "allows subclasses to set a custom collection name" do
          class ::CustomCollectionName < Document; end
          class ::CustomCollectionNameSubclass < ::CustomCollectionName
            self.collection_name = 'custom'
          end

          ::CustomCollectionNameSubclass.collection_name.should == 'custom'
        end
      end

      describe "#collection" do
        it "is an instrumented collection" do
          User.collection.should be_a(InstrumentedCollection)
        end

        it "uses the correct collection name" do
          User.collection.name.should == 'users'
        end

        it "is updated when the collection name changes" do
          collection = User.collection
          User.collection_name = "custom"
          User.collection.name.should == "custom"
        end
      end

      describe "#database" do
        it "returns the current database" do
          User.database.should == MongoModel.database
        end
      end

      describe "#create" do
        context "attributes hash" do
          it "passes attributes to instance" do
            @user = User.create(:name => 'Test', :age => 18)
            @user.name.should == 'Test'
            @user.age.should == 18
          end

          it "saves the instance" do
            User.create.should_not be_a_new_record
          end

          it "yields the instance to a given block before saving" do
            block_called = false

            User.create do |u|
              block_called = true

              u.should be_an_instance_of(User)
              u.should be_a_new_record
            end

            block_called.should be true
          end
        end

        context "array of attribute hashes" do
          def create_users(&block)
            User.create([{ :name => 'Test', :age => 18 }, { :name => 'Second', :age => 21 }], &block)
          end

          it "returns instances in array with associated attributes" do
            @users = create_users
            @users[0].name.should == 'Test'
            @users[0].age.should == 18
            @users[1].name.should == 'Second'
            @users[1].age.should == 21
          end

          it "saves each instance" do
            create_users.each { |user| user.should_not be_a_new_record }
          end

          it "yields each instance to a given block before saving" do
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

        it "deletes by id" do
          User.delete('user-1')

          User.exists?('user-1').should be false
          User.exists?('user-2').should be true
        end

        it "deletes by multiple ids in array" do
          User.delete(['user-1', 'user-2'])

          User.exists?('user-1').should be false
          User.exists?('user-2').should be false
          User.exists?('user-3').should be true
        end
      end

      describe "#delete (instance method)" do
        before(:each) do
          @user = User.create(:id => 'user-1')
          User.create(:id => 'user-2', :name => 'Another')
        end

        it "deletes the instance from the database" do
          @user.delete

          User.exists?('user-1').should be false
          User.exists?('user-2').should be true
        end

        it "returns the instance" do
          @user.delete.should == @user
        end

        it "freezes the instance" do
          @user.delete
          @user.should be_frozen
        end

        it "marks the instance as destroyed" do
          @user.delete
          @user.should be_destroyed
        end
      end

      describe "#destroy (instance method)" do
        before(:each) do
          @user = User.create(:id => 'user-1')
          User.create(:id => 'user-2', :name => 'Another')
        end

        it "deletes the instance from the database" do
          @user.destroy

          User.exists?('user-1').should be false
          User.exists?('user-2').should be true
        end

        it "returns the instance" do
          @user.destroy.should == @user
        end

        it "freezes the instance" do
          @user.destroy
          @user.should be_frozen
        end

        it "marks the instance as destroyed" do
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

        it "destroys by id" do
          User.destroy('user-1')

          User.exists?('user-1').should be false
          User.exists?('user-2').should be true
        end

        it "destroys by multiple ids in array" do
          User.destroy(['user-1', 'user-2'])

          User.exists?('user-1').should be false
          User.exists?('user-2').should be false
          User.exists?('user-3').should be true
        end
      end

      describe "#update_attributes" do
        let(:user) { User.new(:name => 'Original', :age => 10) }

        before(:each) { user.update_attributes(:name => 'Changed', :age => 20) }

        it "updates the attributes" do
          user.name.should == 'Changed'
          user.age.should == 20
        end

        it "saves the document" do
          user.should_not be_a_new_record
        end
      end

      describe "#update_attribute" do
        let(:user) { User.new(:name => 'Original', :age => 10) }

        before(:each) { user.update_attribute(:name, 'Changed') }

        it "updates the given attribute" do
          user.name.should == 'Changed'
        end

        it "saves the document" do
          user.should_not be_a_new_record
        end
      end

      describe "#reload" do
        define_class(:UserComment, Document) do
          property :title, String
          property :body, String

          belongs_to :user
        end

        let(:user) { User.create!(:name => "Bob") }

        subject { UserComment.create!(:title => "Test", :user => user) }

        it "returns itself" do
          subject.reload.should == subject
        end

        it "resets the attributes" do
          subject.title = "New Value"
          subject.body = "Blah blah blah"
          subject.reload
          subject.title.should == "Test"
          subject.body.should == nil
        end

        it "resets the associations" do
          subject.user.should == user
          subject.user = User.new(:name => "Bill")
          subject.reload
          subject.user.should == user
        end
      end
    end
  end
end
