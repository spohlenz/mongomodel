require 'spec_helper'

module MongoModel
  describe Document do
    define_class(:Article, Document) do
      property :title, String
      property :age, Integer
    end
    
    def subclass(klass)
      Class.new(klass)
    end
    
    it "should have an indexes collection" do
      Article.indexes.should == []
    end
    
    it "should inherit indexes from parent classes" do
      index = mock('index')
      Article.indexes << index
      subclass(Article).indexes.should == [index]
    end
    
    describe "#index" do
      it "should add an index to the indexes collection" do
        Article.index :title, :unique => true
        Article.indexes.first.should == Index.new(:title, :unique => true)
      end
      
      it "should mark indexes as uninitialized" do
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
      end
      
      it "should create indexes on the collection" do
        Article.collection.should_receive(:create_index).with(:title, true)
        Article.collection.should_receive(:create_index).with([[:age, Mongo::DESCENDING]])
        Article.ensure_indexes!
      end
      
      it "should mark indexes as initialized" do
        Article.indexes_initialized?.should be_false
        Article.ensure_indexes!
        Article.indexes_initialized?.should be_true
      end
    end
    
    describe "#_find" do
      it "should run ensure_indexes!" do
        Article.should_receive(:ensure_indexes!)
        Article.find(:first)
      end
      
      it "should rerun ensure_indexes! if indexes are initialized" do
        Article.ensure_indexes!
        Article.should_not_receive(:ensure_indexes!)
        Article.find(:first)
      end
    end
  end
  
  describe Index do
    it "should convert index with single key to arguments for Mongo::Collection#create_index" do
      Index.new(:title).to_args.should == [:title]
    end
    
    it "should convert nested index with single key to arguments for Mongo::Collection#create_index" do
      Index.new('page.title').to_args.should == [:'page.title']
    end
    
    it "should convert index with unique option to arguments for Mongo::Collection#create_index" do
      Index.new(:title, :unique => true).to_args.should == [:title, true]
    end
    
    it "should convert index with descending key to arguments for Mongo::Collection#create_index" do
      Index.new(:title => :descending).to_args.should == [[[:title, Mongo::DESCENDING]]]
    end
    
    it "should convert index with multiple keys to arguments for Mongo::Collection#create_index" do
      Index.new(:title, :age).to_args.should == [[[:age, Mongo::ASCENDING], [:title, Mongo::ASCENDING]]]
    end
    
    it "should convert index with multiple keys (ascending and descending) to arguments for Mongo::Collection#create_index" do
      Index.new(:title => :ascending, :age => :descending).to_args.should == [[[:age, Mongo::DESCENDING], [:title, Mongo::ASCENDING]]]
    end
    
    it "should be equal to an equivalent index" do
      Index.new(:title).should == Index.new(:title)
      Index.new(:title, :age).should == Index.new(:title => :ascending, :age => :ascending)
    end
    
    it "should not be equal to an non-equivalent index" do
      Index.new(:title).should_not == Index.new(:age)
      Index.new(:title, :age).should_not == Index.new(:title => :ascending, :age => :descending)
    end
  end
end
