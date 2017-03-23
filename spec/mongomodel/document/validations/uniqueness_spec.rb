require 'spec_helper'

module MongoModel
  specs_for(Document) do
    describe "validates_uniqueness_of" do
      shared_examples_for "beating the race condition" do
        before(:each) do
          subject.stub(:valid?).and_return(true, false)
        end

        describe "save" do
          it "returns false" do
            subject.save.should be false
          end

          it "adds errors to the instance" do
            subject.save
            subject.errors[:title].should_not be_nil
          end
        end

        describe "save!" do
          it "raises a DocumentInvalid exception" do
            lambda { subject.save! }.should raise_error(DocumentInvalid)
          end

          it "adds errors to the instance" do
            subject.save! rescue nil
            subject.errors[:title].should_not be_nil
          end
        end
      end

      describe "indexes" do
        define_class(:Article, Document) do
          property :title, String
        end

        it "creates an index on the attribute" do
          Article.should_receive(:index).with(:title, :unique => true)
          Article.validates_uniqueness_of :title
        end

        it "creates an index on the lowercase attribute if :case_sensitive => false" do
          Article.should_receive(:index).with("_lowercase_title", :unique => true)
          Article.validates_uniqueness_of :title, :case_sensitive => false
        end

        it "creates a compound index when a scope is passed" do
          Article.should_receive(:index).with(:title, :author_id, :unique => true)
          Article.validates_uniqueness_of :title, :scope => :author_id
        end

        it "does not create an index if :index => false" do
          Article.should_not_receive(:index)
          Article.validates_uniqueness_of :title, :index => false
        end
      end

      describe "basic case" do
        define_class(:Article, Document) do
          property :title, String
          validates_uniqueness_of :title
        end

        subject { Article.new(:title => 'Test') }

        it "is valid if no document with same title exists" do
          subject.should be_valid
        end

        it "is not valid if document with same title exists" do
          Article.create!(:title => 'Test')
          subject.should_not be_valid
        end

        it "is valid if document with different-cased title exists" do
          Article.create!(:title => 'TEST')
          subject.should be_valid
        end

        it "is valid if document already saved and no other document with same title exists" do
          subject.save!
          subject.should be_valid
        end

        it "generates correct error message" do
          Article.create!(:title => 'Test')
          subject.valid?
          subject.errors[:title].should include('has already been taken')
        end

        describe "beating the race condition" do
          before(:each) { Article.create!(:title => 'Test') }
          it_should_behave_like "beating the race condition"
        end
      end

      describe "with single scope" do
        define_class(:Article, Document) do
          property :title, String
          property :category, String
          validates_uniqueness_of :title, :scope => :category
        end

        before(:each) do
          Article.create!(:title => 'Test', :category => 'Development')
        end

        subject { Article.new(:title => 'Test', :category => 'Testing') }

        describe "no document with same title and category exists" do
          it { should be_valid }
        end

        describe "document with same title and category exists" do
          before(:each) { Article.create!(:title => 'Test', :category => 'Testing') }
          it { should_not be_valid }
        end

        describe "document already saved" do
          before(:each) { subject.save! }
          it { should be_valid }
        end

        describe "beating the race condition" do
          before(:each) { Article.create!(:title => 'Test', :category => 'Testing') }
          it_should_behave_like "beating the race condition"
        end
      end

      describe "with array scope" do
        define_class(:Article, Document) do
          property :title, String
          property :category, String
          property :year, Integer
          validates_uniqueness_of :title, :scope => [:category, :year]
        end

        before(:each) do
          Article.create!(:title => 'Test', :category => 'Development', :year => 2008)
        end

        subject { Article.new(:title => 'Test', :category => 'Testing', :year => 2009) }

        describe "no document with same title and category exists" do
          it { should be_valid }
        end

        describe "document with same title and category exists" do
          before(:each) { Article.create!(:title => 'Test', :category => 'Testing', :year => 2009) }
          it { should_not be_valid }
        end

        describe "document already saved" do
          before(:each) { subject.save! }
          it { should be_valid }
        end

        describe "beating the race condition" do
          before(:each) { Article.create!(:title => 'Test', :category => 'Testing', :year => 2009) }
          it_should_behave_like "beating the race condition"
        end
      end

      describe "case insensitive" do
        define_class(:Article, Document) do
          property :title, String
          validates_uniqueness_of :title, :case_sensitive => false
        end

        subject { Article.new(:title => 'Test') }

        describe "no document with same title exists" do
          it { should be_valid }
        end

        describe "document with same title exists" do
          before(:each) { Article.create!(:title => 'Test') }
          it { should_not be_valid }
        end

        describe "document with different-cased title exists" do
          before(:each) { Article.create!(:title => 'TEST') }
          it { should_not be_valid }
        end

        describe "document already saved" do
          before(:each) { subject.save! }
          it { should be_valid }
        end

        describe "beating the race condition" do
          before(:each) { Article.create!(:title => 'TEST') }
          it_should_behave_like "beating the race condition"
        end
      end

      describe "validation on parent class" do
        define_class(:Article, Document) do
          property :title, String
          validates_uniqueness_of :title
        end
        define_class(:SpecialArticle, :Article)

        subject { SpecialArticle.new(:title => 'Test') }

        describe "no document with same title exists" do
          it { should be_valid }
        end

        describe "parent document with same title exists" do
          before(:each) { Article.create!(:title => 'Test') }
          it { should_not be_valid }
        end

        describe "child document with same title exists" do
          before(:each) { SpecialArticle.create!(:title => 'Test') }
          it { should_not be_valid }
        end
      end

      describe "validation on child class" do
        define_class(:Article, Document) do
          property :title, String
        end
        define_class(:SpecialArticle, :Article) do
          validates_uniqueness_of :title
        end

        subject { SpecialArticle.new(:title => 'Test') }

        describe "no document with same title exists" do
          it { should be_valid }
        end

        describe "parent document with same title exists" do
          before(:each) { Article.create!(:title => 'Test') }
          it { should be_valid }
        end

        describe "child document with same title exists" do
          before(:each) { SpecialArticle.create!(:title => 'Test') }
          it { should_not be_valid }
        end
      end
    end
  end
end
