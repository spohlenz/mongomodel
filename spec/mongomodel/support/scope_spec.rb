require 'spec_helper'

module MongoModel
  describe Scope do
    define_class(:Post, Document) do
      property :published, Boolean, :default => false
      property :author, String
    end
  
    subject { Scope.new(Post) }
    
    def self.when_loaded(subject=:subject, &block)
      context "when loaded" do
        before(:each) { send(subject).to_a }
        class_eval(&block)
      end
    end
    
    def self.when_unloaded(subject=:subject, &block)
      context "when not loaded", &block
    end
    
    def self.always(&block)
      when_loaded(&block)
      when_unloaded(&block)
    end
    
    when_unloaded do
      it { should_not be_loaded }
    end
    
    when_loaded do
      it { should be_loaded }
    end
    
    describe "#to_a" do
      before(:each) do
        @posts = (1..5).map { Post.create! }
      end
      
      when_unloaded do
        it "should perform find on collection" do
          Post.should find_with({})
          subject.to_a
        end
      
        it "should return documents" do
          subject.to_a.should == @posts
        end
      end
      
      when_loaded do
        it "should not perform find on collection" do
          Post.collection.should_not_receive(:find)
          subject.to_a
        end
        
        it "should return loaded documents" do
          subject.to_a.should == @posts
        end
      end
    end
    
    describe "#count" do
      always do
        it "should perform a count on the collection" do
          Post.should count_with({}).and_return(4)
          subject.count.should == 4
        end
      end
    end
    
    describe "#size" do
      before(:each) do
        5.times { Post.create! }
      end
      
      when_unloaded do
        it "should perform a count on the collection" do
          Post.should count_with({}).and_return(5)
          subject.size.should == 5
        end
      end
      
      when_loaded do
        it "should not perform a count on the collection" do
          Post.collection.should_not_receive(:find)
          subject.size.should == 5
        end
      end
    end
    
    describe "#empty?" do
      context "when no matching documents exist" do
        always do
          it { should be_empty }
        end
      end
      
      context "when matching documents exist" do
        before(:each) { Post.create! }
        
        always do
          it { should_not be_empty }
        end
      end
      
      when_loaded do
        it "should not perform a count on the collection" do
          Post.collection.should_not_receive(:find)
          subject.empty?
        end
      end
    end
    
    describe "#any?" do
      context "when no matching documents exist" do
        always do
          it "should return false" do
            subject.any?.should be_false
          end
        end
      end
      
      context "when matching documents exist" do
        before(:each) { Post.create! }
        
        always do
          it "should return true" do
            subject.any?.should be_true
          end
        end
      end
      
      context "when no block given" do
        it "should perform a count on the collection" do
          Post.should count_with({})
          subject.any?
        end
      end
    end
    
    describe "#reset" do
      always do
        it "should return self" do
          subject.reset.should equal(subject)
        end
        
        it "should not be loaded" do
          subject.reset
          subject.should_not be_loaded
        end
      end
    end
    
    describe "#reload" do
      always do
        it "should return self" do
          subject.reset.should equal(subject)
        end
        
        it "should be loaded" do
          subject.reload
          subject.should be_loaded
        end
      end
    end
    
    describe "#inspect" do
      before(:each) do
        5.times { Post.create! }
      end
      
      it "should delegate to to_a" do
        subject.inspect.should == subject.to_a.inspect
      end
    end
    
    describe "#==" do
      before(:each) do
        @posts = (1..5).map { Post.create! }
      end
      
      it "should be equal to a scope for the same class" do
        subject.should == Scope.new(Post)
      end
      
      it "should be equal to an array with matching results" do
        subject.should == @posts
      end
      
      it "should not be equal to an array with different results" do
        subject.should_not == @posts.reverse
      end
    end
    
    describe "array methods" do
      before(:each) do
        @post = Post.create!
      end
      
      specify "[] should be forwarded to to_a" do
        subject[0].should == @post
      end
      
      specify "each should be forwarded to to_a" do
        subject.each do |post|
          post.should == @post
        end
      end
    end
    
    describe "#where" do
      let(:scope) { subject.where(:published => true) }
      
      when_loaded do
        it "should not be loaded" do
          scope.should_not be_loaded
        end
      end
      
      it "should return a new scope" do
        scope.should be_an_instance_of(MongoModel::Scope)
      end
      
      it "should add the where values" do
        scope.where_values.should == [{ :published => true }]
      end
      
      it "should accept multiple where values at once" do
        scope = subject.where({ :published => false }, { :author => "John" })
        scope.where_values.should == [{ :published => false }, { :author => "John" }]
      end
      
      it "should append multiple where values" do
        new_scope = scope.where(:author => "Sam")
        new_scope.where_values.should == [{ :published => true }, { :author => "Sam" }]
      end
      
      it "should use where values as conditions in finder options" do
        scope.finder_options.should == { :conditions => { :published => true } }
      end
      
      it "should combine multiple where values into single conditions hash" do
        new_scope = scope.where(:author => "Sam")
        new_scope.finder_options.should == { :conditions => { :published => true, :author => "Sam" } }
      end
    end
    
    describe "#select" do
      let(:scope) { subject.select(:author) }
      
      when_loaded do
        it "should not be loaded" do
          scope.should_not be_loaded
        end
      end
      
      it "should return a new scope" do
        scope.should be_an_instance_of(MongoModel::Scope)
      end
      
      it "should add the select values" do
        scope.select_values.should == [:author]
      end
      
      it "should accept multiple select values at once" do
        scope = subject.select(:id, :author)
        scope.select_values.should == [:id, :author]
      end
      
      it "should append multiple select values" do
        new_scope = scope.select(:id)
        new_scope.select_values.should == [:author, :id]
      end
      
      it "should use select values in finder options" do
        scope.finder_options.should == { :select => [:author] }
      end
    end
    
    describe "#order" do
      let(:scope) { subject.order(:author.asc) }
      
      when_loaded do
        it "should not be loaded" do
          scope.should_not be_loaded
        end
      end
      
      it "should return a new scope" do
        scope.should be_an_instance_of(MongoModel::Scope)
      end
      
      it "should add the order values" do
        scope.order_values.should == [:author.asc]
      end
      
      it "should accept multiple order values at once" do
        scope = subject.order(:published.desc, :author.asc)
        scope.order_values.should == [:published.desc, :author.asc]
      end
      
      it "should append multiple order values" do
        new_scope = scope.order(:published.asc)
        new_scope.order_values.should == [:author.asc, :published.asc]
      end
      
      it "should use order values in finder options" do
        scope.finder_options.should == { :order => [:author.asc] }
      end
    end
    
    describe "#limit" do
      let(:scope) { subject.limit(3) }
      
      when_loaded do
        it "should not be loaded" do
          scope.should_not be_loaded
        end
      end
      
      it "should return a new scope" do
        scope.should be_an_instance_of(MongoModel::Scope)
      end
      
      it "should set the limit value" do
        scope.limit_value.should == 3
      end
      
      it "should override previous limit value" do
        new_scope = scope.limit(8)
        new_scope.limit_value.should == 8
      end
      
      it "should use limit value in finder options" do
        scope.finder_options.should == { :limit => 3 }
      end
    end
    
    describe "#offset" do
      let(:scope) { subject.offset(10) }
      
      when_loaded do
        it "should not be loaded" do
          scope.should_not be_loaded
        end
      end
      
      it "should return a new scope" do
        scope.should be_an_instance_of(MongoModel::Scope)
      end
      
      it "should set the offset value" do
        scope.offset_value.should == 10
      end
      
      it "should override previous offset value" do
        new_scope = scope.offset(20)
        new_scope.offset_value.should == 20
      end
      
      it "should use offset value in finder options" do
        scope.finder_options.should == { :offset => 10 }
      end
    end
    
    describe "#from" do
      define_class(:OtherPost, Document) do
        self.collection_name = "my_posts"
      end
      
      let(:scope) { subject.from(OtherPost.collection) }
      
      when_loaded do
        it "should not be loaded" do
          scope.should_not be_loaded
        end
      end
      
      it "should return a new scope" do
        scope.should be_an_instance_of(MongoModel::Scope)
      end
      
      it "should set the collection" do
        scope.collection.should == OtherPost.collection
      end
      
      it "should use the collection when finding" do
        Post.collection.should_not_receive(:find)
        OtherPost.should find_with({})
        scope.to_a
      end
    end
    
    describe "#reverse_order" do
      let(:ordered) { subject.order(:author.asc) }
      let(:reverse) { ordered.reverse_order }
      
      when_loaded(:ordered) do
        it "should not be loaded" do
          reverse.should_not be_loaded
        end
      end
      
      it "should return a new scope" do
        reverse.should be_an_instance_of(MongoModel::Scope)
      end
      
      it "should set the order values to the reverse order" do
        reverse.order_values.should == [:author.desc]
      end
      
      context "when no order set" do
        it "should set the order value to descending by id" do
          subject.reverse_order.order_values.should == [:id.desc]
        end
      end
    end
    
    describe "#except" do
      define_class(:OtherPost, Document) do
        self.collection_name = "my_posts"
      end
      
      let(:scope) do
        subject.where(:author => "Sam").
                where(:published => true).
                order(:author.asc).
                order(:published.desc).
                select(:author).
                select(:published).
                offset(15).
                limit(7).
                from(OtherPost.collection)
      end
      
      context "given :where" do
        it "should return a new scope without where values" do
          s = scope.except(:where)
          s.where_values.should be_empty
          s.order_values.should == [:author.asc, :published.desc]
          s.select_values.should == [:author, :published]
          s.offset_value.should == 15
          s.limit_value.should == 7
          s.collection.should == OtherPost.collection
        end
      end
      
      context "given :order" do
        it "should return a new scope without order values" do
          s = scope.except(:order)
          s.where_values.should == [{ :author => "Sam" }, { :published => true }]
          s.order_values.should be_empty
          s.select_values.should == [:author, :published]
          s.offset_value.should == 15
          s.limit_value.should == 7
          s.collection.should == OtherPost.collection
        end
      end
      
      context "given :select" do
        it "should return a new scope without select values" do
          s = scope.except(:select)
          s.where_values.should == [{ :author => "Sam" }, { :published => true }]
          s.order_values.should == [:author.asc, :published.desc]
          s.select_values.should be_empty
          s.offset_value.should == 15
          s.limit_value.should == 7
          s.collection.should == OtherPost.collection
        end
      end
      
      context "given :offset" do
        it "should return a new scope without offset value" do
          s = scope.except(:offset)
          s.where_values.should == [{ :author => "Sam" }, { :published => true }]
          s.order_values.should == [:author.asc, :published.desc]
          s.select_values.should == [:author, :published]
          s.offset_value.should be_nil
          s.limit_value.should == 7
          s.collection.should == OtherPost.collection
        end
      end
      
      context "given :limit" do
        it "should return a new scope without limit value" do
          s = scope.except(:limit)
          s.where_values.should == [{ :author => "Sam" }, { :published => true }]
          s.order_values.should == [:author.asc, :published.desc]
          s.select_values.should == [:author, :published]
          s.offset_value.should == 15
          s.limit_value.should be_nil
          s.collection.should == OtherPost.collection
        end
      end
      
      context "given :from" do
        it "should return a new scope with default collection" do
          s = scope.except(:from)
          s.where_values.should == [{ :author => "Sam" }, { :published => true }]
          s.order_values.should == [:author.asc, :published.desc]
          s.select_values.should == [:author, :published]
          s.offset_value.should == 15
          s.limit_value.should == 7
          s.collection.should == Post.collection
        end
      end
    end
    
    describe "#first" do
      let(:scope) { subject.order(:author.asc) }
      
      context "when no matching documents exist" do
        always do
          it "should return nil" do
            scope.first.should be_nil
          end
        end
        
        when_loaded(:scope) do
          it "should not perform a find" do
            Post.collection.should_not_receive(:find)
            scope.first
          end
        end
        
        when_unloaded(:scope) do
          it "should find with a limit of 1" do
            Post.should find_with(:limit => 1, :order => :author.asc)
            scope.first
          end
        end
      end
      
      context "when a matching document exists" do
        before(:each) do
          @expected = Post.create!(:author => "A")
          Post.create!(:author => "B")
          Post.create!(:author => "C")
        end
        
        always do
          it "should return the first document" do
            scope.first.should == @expected
          end
        end
        
        when_unloaded do
          it "should cache find result" do
            Post.should find_with(:limit => 1, :order => :author.asc).and_return([@expected])
            scope.first
            scope.first
          end
        end
      end
    end
    
    describe "#last" do
      let(:scope) { subject.order(:author.asc) }
      
      context "when no matching documents exist" do
        always do
          it "should return nil" do
            scope.last.should be_nil
          end
        end
        
        when_loaded(:scope) do
          it "should not perform a find" do
            Post.collection.should_not_receive(:find)
            scope.last
          end
        end
        
        when_unloaded(:scope) do
          it "should find with a limit of 1 and reverse order" do
            Post.should find_with(:limit => 1, :order => :author.desc)
            scope.last
          end
        end
      end
      
      context "when a matching document exists" do
        before(:each) do
          Post.create!(:author => "A")
          Post.create!(:author => "B")
          @expected = Post.create!(:author => "C")
        end
        
        always do
          it "should return the last document" do
            scope.last.should == @expected
          end
        end
        
        when_unloaded do
          it "should cache find result" do
            Post.should find_with(:limit => 1, :order => :author.desc).and_return([@expected])
            scope.last
            scope.last
          end
        end
      end
    end
    
    describe "#all" do
      before(:each) do
        @posts = (1..5).map { Post.create! }
      end
      
      it "should return posts" do
        subject.all.should == @posts
      end
    end
    
    describe "#find" do
      before(:each) do
        @first = Post.create!(:author => "Aaron")
        @post = Post.create!(:author => "Bob")
        @last = Post.create!(:author => "Charlie")
      end
      
      context "with single id" do
        context "when document exists" do
          it "should return document" do
            subject.find(@post.id).should == @post
          end
        end
        
        context "when document does not exist" do
          it "should raise a DocumentNotFound exception" do
            lambda {
              subject.find('missing')
            }.should raise_error(MongoModel::DocumentNotFound)
          end
        end
      end
      
      context "by multiple ids" do
        context "when all documents exist" do
          it "should return documents in order given" do
            subject.find(@last.id, @first.id).should == [@last, @first]
          end
        end
        
        context "when some documents do not exist" do
          it "should raise a DocumentNotFound exception" do
            lambda {
              subject.find(@post.id, 'missing')
            }.should raise_error(MongoModel::DocumentNotFound)
          end
        end
      end
    end
    
    describe "#exists?" do
      before(:each) do
        @post = Post.create!
      end
      
      context "when the document exists" do
        it "should return true" do
          subject.exists?(@post.id).should be_true
        end
      end
      
      context "when the document does not exist" do
        it "should return false" do
          subject.exists?('missing').should be_false
        end
      end
    end
  end
end
