require 'spec_helper'

module MongoModel
  describe Document do
    describe "indexes" do
      define_class(:Article, Document) do
        property :title, String
        property :age, Integer
        property :position, Array
      end
    
      def subclass(klass)
        Class.new(klass)
      end
    
      it "has an indexes collection" do
        Article.indexes.should be_an_instance_of(Array)
      end
    
      it "inherits indexes from parent classes" do
        index = double('index')
        Article.indexes << index
        subclass(Article).indexes.should include(index)
      end
    
      describe "#index" do
        it "adds an index to the indexes collection" do
          Article.index :title, :unique => true
          Article.indexes.last.should == Index.new(:title, :unique => true)
        end
      
        it "marks indexes as uninitialized" do
          Article.ensure_indexes!
        
          Article.indexes_initialized?.should be_true
          Article.index :age
          Article.indexes_initialized?.should be_false
        end
      end
    
      describe "#ensure_indexes!" do
        before(:each) do
          Article.index :title, :unique => true
          Article.index :age => :descending
          Article.index :position => :geo2d, :min => -100, :max => 100
        end
      
        it "creates indexes on the collection" do
          Article.collection.should_receive(:create_index).with(:_type)
          Article.collection.should_receive(:create_index).with(:title, :unique => true)
          Article.collection.should_receive(:create_index).with([[:age, Mongo::DESCENDING]])
          Article.collection.should_receive(:create_index).with([[:position, Mongo::GEO2D]], :min => -100, :max => 100)
          Article.ensure_indexes!
        end
      
        it "marks indexes as initialized" do
          Article.indexes_initialized?.should be_false
          Article.ensure_indexes!
          Article.indexes_initialized?.should be_true
        end
      end
    
      describe "#_find" do
        it "runs ensure_indexes!" do
          Article.should_receive(:ensure_indexes!)
          Article.first
        end
      
        it "reruns ensure_indexes! if indexes are initialized" do
          Article.ensure_indexes!
          Article.should_not_receive(:ensure_indexes!)
          Article.first
        end
      end
    end
    
    describe "index shortcuts" do
      define_class(:TestDocument, Document)
      
      describe ":index => true" do
        it "adds an index on the property" do
          TestDocument.should_receive(:index).with(:title)
          TestDocument.property :title, String, :index => true
        end
      end
    end
  end
  
  describe Index do
    describe "#to_args" do
      it "converts index with single key" do
        Index.new(:title).to_args.should == [:title]
      end
    
      it "converts nested index with single key" do
        Index.new('page.title').to_args.should == [:'page.title']
      end
    
      it "converts index with unique option" do
        Index.new(:title, :unique => true).to_args.should == [:title, { :unique => true }]
      end
      
      it "converts index with name option" do
        Index.new(:title, :name => "my_name").to_args.should == [:title, { :name => "my_name" }]
      end
      
      it "converts index with multiple options" do
        Index.new(:title, :name => "my_name", :unique => true).to_args.should == [:title, { :name => "my_name", :unique => true }]
      end
    
      it "converts index with descending key" do
        Index.new(:title => :descending).to_args.should == [[[:title, Mongo::DESCENDING]]]
      end
    
      it "converts index with multiple keys" do
        Index.new(:title, :age).to_args.should == [[[:age, Mongo::ASCENDING], [:title, Mongo::ASCENDING]]]
      end
    
      it "converts index with multiple keys (ascending and descending)" do
        Index.new(:title => :ascending, :age => :descending).to_args.should == [[[:age, Mongo::DESCENDING], [:title, Mongo::ASCENDING]]]
      end
    
      it "converts geospatial index with no options" do
        Index.new(:position => :geo2d).to_args.should == [[[:position, Mongo::GEO2D]]]
      end
    
      it "converts geospatial index with min/max options" do
        Index.new(:position => :geo2d, :min => -50, :max => 50).to_args.should == [[[:position, Mongo::GEO2D]], { :min => -50, :max => 50 }]
      end
    end
    
    describe "equality" do
      it "is equal to an equivalent index" do
        Index.new(:title).should == Index.new(:title)
        Index.new(:title, :age).should == Index.new(:title => :ascending, :age => :ascending)
      end
    
      it "is not equal to an non-equivalent index" do
        Index.new(:title).should_not == Index.new(:age)
        Index.new(:title, :age).should_not == Index.new(:title => :ascending, :age => :descending)
      end
    end
  end
end
