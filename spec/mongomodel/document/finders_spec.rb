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

          it "returns a User" do
            subject.should be_a(User)
          end

          it "loads the document attributes" do
            subject.id.should == '2'
            subject.name.should == 'Alistair'
          end

          it { should_not be_a_new_record }

          it "stringifies ids" do
            User.find(2).id.should == '2'
          end
        end

        context "document does not exist" do
          it "raises a DocumentNotFound exception" do
            lambda {
              User.find('4')
            }.should raise_error(MongoModel::DocumentNotFound)
          end
        end

        context "no id specified" do
          it "raises an ArgumentError" do
            lambda {
              User.find
            }.should raise_error(ArgumentError)
          end
        end
      end

      describe "by multiple ids" do
        context "all documents exist" do
          subject { User.find('1', '2') }

          it "returns an array of Users" do
            subject[0].should be_a(User)
            subject[1].should be_a(User)
          end

          it "loads document attributes" do
            subject[0].name.should == 'Fred'
            subject[1].name.should == 'Alistair'
          end

          it "loads documents in correct order" do
            result = User.find('2', '1')
            result[0].id.should == '2'
            result[1].id.should == '1'
          end
        end

        context "some documents missing" do
          it "raises a DocumentNotFound exception" do
            lambda {
              User.find('1', '2', '4')
            }.should raise_error(MongoModel::DocumentNotFound)
          end
        end
      end
    end
  end
end
