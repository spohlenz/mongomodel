require 'spec_helper'
require 'active_support/time'

module MongoModel
  describe Scope do
    define_class(:Post, Document) do
      property :published, Boolean, :default => false
      property :author, String
      property :date, Time
    end
    
    let(:basic_scope) { Scope.new(Post) }
    let(:posts) { (1..5).map { Post.new } }
    
    subject { Scope.new(Post) }
    
    MongoModel::Document.extend(DocumentFinderStubs)
    
    
    def self.subject_loaded(&block)
      context "when loaded" do
        before(:each) { subject.to_a }
        class_eval(&block)
      end
    end
    
    def self.subject_not_loaded(&block)
      context "when not loaded", &block
    end
    
    def self.always(&block)
      subject_loaded(&block)
      subject_not_loaded(&block)
    end
    
    
    shared_examples_for "all scopes" do
      def finder_conditions
        finder_options[:conditions] || {}
      end
      
      describe "#to_a" do
        it "finds and return documents matching conditions" do
          model.should_find(finder_options, posts) do
            subject.to_a.should == posts
          end
        end
        
        it "loads the scope" do
          subject.to_a
          subject.should be_loaded
        end
        
        it "caches the documents" do
          subject.to_a
          model.should_not_find { subject.to_a }
        end
      end
      
      describe "#as_json" do
        it "delegates to #to_a" do
          subject.as_json.should == subject.to_a.as_json
        end
      end
      
      describe "#count" do
        it "counts documents matching conditions and return the result" do
          model.should_count(finder_options, 4) do
            subject.count
          end
        end
        
        it "does not cache the result" do
          subject.count
          model.should_count(finder_options, 4) do
            subject.count.should == 4
          end
        end
      end
      
      describe "#size" do
        before(:each) { model.stub_find(posts) }
        
        subject_loaded do
          it "returns the number of matching documents" do
            subject.size.should == 5
          end
          
          it "does not perform a count on the collection" do
            model.should_not_count { subject.size }
          end
        end
        
        subject_not_loaded do
          it "returns the number of matching documents" do
            subject.size.should == 5
          end
          
          it "performs a count on the collection" do
            model.should_count(finder_options, 9) do
              subject.size.should == 9
            end
          end
        end
      end
      
      describe "#empty?" do
        context "when no matching documents exist" do
          before(:each) { model.stub_find([]) }
          
          always do
            it { should be_empty }
          end
        end
        
        context "when matching documents exist" do
          before(:each) { model.stub_find(posts) }
          
          always do
            it { should_not be_empty }
          end
        end
        
        subject_loaded do
          it "does not perform a count on the collection" do
            model.should_not_count { subject.empty? }
          end
        end
      end
      
      describe "#any?" do
        context "when no block given" do
          it "performs a count on the collection" do
            model.should_count(finder_options, 1) { subject.any? }
          end
          
          context "when no matching documents exist" do
            before(:each) { model.stub_find([]) }

            always do
              specify { subject.any?.should be_false }
            end
          end

          context "when matching documents exist" do
            before(:each) { model.stub_find(posts) }

            always do
              specify { subject.any?.should be_true }
            end
          end
        end
        
        context "when block given" do
          it "delegates block to to_a" do
            blk = lambda { |*args| true }
            subject.to_a.should_receive(:any?).with(&blk)
            subject.any?(&blk)
          end
        end
      end
      
      describe "#reset" do
        always do
          it "returns itself" do
            subject.reset.should equal(subject)
          end

          it "is not loaded" do
            subject.reset
            subject.should_not be_loaded
          end
        end
      end
      
      describe "#reload" do
        always do
          it "returns itself" do
            subject.reload.should equal(subject)
          end

          it "is loaded after calling" do
            subject.reload
            subject.should be_loaded
          end
          
          it "resets its finder options" do
            old_finder_options = subject.finder_options
            subject.reload.finder_options.should_not equal(old_finder_options)
          end

          it "resets its options for create" do
            old_options_for_create = subject.options_for_create
            subject.reload.options_for_create.should_not equal(old_options_for_create)
          end
        end
      end
      
      describe "#==" do
        before(:each) { model.stub_find(posts) }
        
        it "is equal to an array with matching results" do
          subject.should == posts
        end

        it "is not equal to an array with different results" do
          subject.should_not == []
        end
      end
      
      describe "array methods" do
        it "forwards [] to to_a" do
          subject.to_a.should_receive(:[]).with(0)
          subject[0]
        end

        it "forwards each to to_a" do
          blk = lambda { |*args| true }
          subject.to_a.should_receive(:each).with(&blk)
          subject.each(&blk)
        end
      end
      
      describe "#where" do
        it "returns a new scope" do
          subject.where(:author => "Sam").should be_an_instance_of(Scope)
        end
        
        it "is not loaded" do
          subject.to_a
          subject.where(:author => "Sam").should_not be_loaded
        end
        
        it "adds individual where values" do
          where_scope = subject.where(:author => "Sam")
          where_scope.where_values.should == subject.where_values + [{ :author => "Sam" }]
        end
        
        it "adds multiple where values" do
          where_scope = subject.where({ :author => "Sam" }, { :published => false })
          where_scope.where_values.should == subject.where_values + [{ :author => "Sam" }, { :published => false }]
        end
      end
      
      describe "#where!" do
        it "overwrites where values" do
          where_scope = subject.where!(:author => "Sam")
          where_scope.where_values.should == [{ :author => "Sam" }]
        end
      end
      
      describe "#order" do
        it "returns a new scope" do
          subject.order(:author.asc).should be_an_instance_of(Scope)
        end
        
        it "is not loaded" do
          subject.to_a
          subject.order(:author.asc).should_not be_loaded
        end
        
        it "adds individual order values" do
          order_scope = subject.order(:author.asc)
          order_scope.order_values.should == subject.order_values + [:author.asc]
        end
        
        it "adds multiple order values" do
          order_scope = subject.order(:author.asc, :published.desc)
          order_scope.order_values.should == subject.order_values + [:author.asc, :published.desc]
        end
      end
      
      describe "#order!" do
        it "overwrites order values" do
          order_scope = subject.order!(:author.asc)
          order_scope.order_values.should == [:author.asc]
        end
      end
      
      describe "#select" do
        context "when no block is given" do
          it "returns a new scope" do
            subject.select(:author).should be_an_instance_of(Scope)
          end
        
          it "is not loaded" do
            subject.to_a
            subject.select(:author).should_not be_loaded
          end
        
          it "adds individual select values" do
            select_scope = subject.select(:author)
            select_scope.select_values.should == subject.select_values + [:author]
          end
        
          it "adds multiple select values" do
            select_scope = subject.select(:author, :published)
            select_scope.select_values.should == subject.select_values + [:author, :published]
          end
        end
        
        context "when a block given" do
          it "passed block to to_a#select" do
            blk = lambda { |*args| true }
            subject.to_a.should_receive(:select).with(&blk)
            subject.select(&blk)
          end
        end
      end
      
      describe "#select!" do
        it "overwrites select values" do
          select_scope = subject.select!(:author)
          select_scope.select_values.should == [:author]
        end
      end
      
      describe "#limit" do
        it "returns a new scope" do
          subject.limit(10).should be_an_instance_of(Scope)
        end
        
        it "is not loaded" do
          subject.limit(10).should_not be_loaded
        end
        
        it "overrides previous limit value" do
          subject.limit(10).limit_value.should == 10
        end
      end
      
      describe "#offset" do
        it "returns a new scope" do
          subject.offset(10).should be_an_instance_of(Scope)
        end
        
        it "is not loaded" do
          subject.offset(10).should_not be_loaded
        end
        
        it "overrides previous offset value" do
          subject.offset(10).offset_value.should == 10
        end
      end
      
      describe "#from" do
        define_class(:NotAPost, Document)
        
        it "returns a new scope" do
          subject.from(NotAPost.collection).should be_an_instance_of(Scope)
        end
        
        it "is not loaded" do
          subject.from(NotAPost.collection).should_not be_loaded
        end
        
        it "overrides collection" do
          subject.from(NotAPost.collection).collection.should == NotAPost.collection
        end
        
        it "allows collection to be set using string" do
          subject.from(NotAPost.collection.name).collection.name.should == NotAPost.collection.name
        end
      end
      
      describe "#first" do
        context "with count argument" do
          context "when no matching documents exist" do
            before(:each) { model.stub_find([]) }
          
            always do
              it "returns an empty array" do
                subject.first(3).should == []
              end
            end
          
            subject_loaded do
              it "does not perform a find" do
                model.should_not_find { subject.first(3) }
              end
            end
          
            subject_not_loaded do
              it "finds with a limit of 3" do
                model.should_find(finder_options.merge(:limit => 3), []) { subject.first(3) }
              end
            end
          end
        
          context "when matching documents exist" do
            before(:each) { model.stub_find([posts[0], posts[1], posts[2]]) }
          
            always do
              it "returns the first documents in an array" do
                subject.first(3).should == [posts[0], posts[1], posts[2]]
              end
            end
          end
        end
        
        context "with no argument" do
          context "when no matching documents exist" do
            before(:each) { model.stub_find([]) }
          
            always do
              it "returns nil" do
                subject.first.should be_nil
              end
            end
          
            subject_loaded do
              it "does not perform a find" do
                model.should_not_find { subject.first }
              end
            end
          
            subject_not_loaded do
              it "finds with a limit of 1" do
                model.should_find(finder_options.merge(:limit => 1), []) { subject.first }
              end
            end
          end
        
          context "when matching documents exist" do
            before(:each) { model.stub_find([posts[0]]) }
          
            always do
              it "returns the first document" do
                subject.first.should == posts[0]
              end
            end
          end
        end
      end
      
      describe "#last" do
        def reversed_finder_options
          order = MongoModel::MongoOrder.parse(finder_options[:order] || [:id.asc])
          finder_options.merge(:order => order.reverse.to_a)
        end
        
        context "with count argument" do
          context "when no matching documents exist" do
            before(:each) { model.stub_find([]) }
          
            always do
              it "returns an empty array" do
                subject.last(2).should == []
              end
            end
          
            subject_loaded do
              it "does not perform a find" do
                model.should_not_find { subject.last(2) }
              end
            end
          
            subject_not_loaded do
              it "finds with a limit of 2" do
                model.should_find(reversed_finder_options.merge(:limit => 2), []) { subject.last(2) }
              end
            end
          end
        
          context "when matching documents exist" do
            before(:each) { model.stub_find([posts[0], posts[1]]) }
          
            always do
              it "returns the last documents in an array" do
                subject.last(2).should == [posts[0], posts[1]]
              end
            end
          end
        end
        
        context "with no argument" do
          context "when no matching documents exist" do
            before(:each) { model.stub_find([]) }
          
            always do
              it "returns nil" do
                subject.last.should be_nil
              end
            end
          
            subject_loaded do
              it "does not perform a find" do
                model.should_not_find { subject.last }
              end
            end
          
            subject_not_loaded do
              it "finds with a limit of 1" do
                model.should_find(reversed_finder_options.merge(:limit => 1), []) { subject.last }
              end
            end
          end
        
          context "when matching documents exist" do
            let(:post) { posts.last }
            before(:each) { model.stub_find([post]) }
          
            always do
              it "returns the last document" do
                subject.last.should == post
              end
            end
          end
        end
      end
      
      describe "#all" do
        it "returns all documents" do
          model.should_find(finder_options, posts) do
            subject.all.should == posts
          end
        end
      end
      
      describe "#find" do
        context "with single id" do
          let(:post) { posts.first }
          
          it "performs find on collection" do
            model.should_find(finder_options.deep_merge(:conditions => { :id => post.id }, :limit => 1), [post]) do
              subject.find(post.id)
            end
          end
          
          context "when document exists" do
            before(:each) { model.stub_find([post]) }
            
            it "finds and return document" do
              subject.find(post.id).should == post
            end
          end

          context "when document does not exist" do
            before(:each) { model.stub_find([]) }
            
            it "raises a DocumentNotFound exception" do
              lambda {
                subject.find('missing')
              }.should raise_error(MongoModel::DocumentNotFound)
            end
          end
        end

        context "by multiple ids" do
          let(:post1) { posts.first }
          let(:post2) { posts.last }
          
          it "performs find on collection" do
            model.should_find(finder_options.deep_merge(:conditions => { :id.in => [post2.id, post1.id] }), [post1, post2]) do
              subject.find(post2.id, post1.id)
            end
          end
          
          context "when all documents exist" do
            before(:each) { model.stub_find([post2, post1]) }
            
            it "returns documents in order given" do
              subject.find(post2.id, post1.id).should == [post2, post1]
            end
          end
        
          context "when some documents do not exist" do
            before(:each) { model.stub_find([post1]) }
            
            it "raises a DocumentNotFound exception" do
              lambda {
                subject.find(post1.id, 'missing')
              }.should raise_error(MongoModel::DocumentNotFound)
            end
          end
        end
      end
      
      describe "#exists?" do
        let(:post) { posts.first }

        it "performs a count on the collection" do
          model.should_count(finder_options.deep_merge(:conditions => { :id => post.id }), 1) do
            subject.exists?(post.id)
          end
        end

        context "when the document exists" do
          before(:each) { model.stub_find([post])}
          
          it "returns true" do
            subject.exists?(post.id).should be_true
          end
        end

        context "when the document does not exist" do
          before(:each) { model.stub_find([])}
          
          it "returns false" do
            subject.exists?('missing').should be_false
          end
        end
      end
      
      describe "#delete_all" do
        it "removes all matching documents from collection" do
          model.should_delete(finder_conditions) do
            subject.delete_all
          end
        end
        
        subject_loaded do
          it "resets the scope" do
            subject.delete_all
            subject.should_not be_loaded
          end
        end
      end
      
      describe "#delete" do
        context "by single id" do
          it "removes the document from the collection" do
            model.should_delete(finder_conditions.merge(:id => "the-id")) do
              subject.delete("the-id")
            end
          end
          
          subject_loaded do
            it "resets the scope" do
              subject.delete("the-id")
              subject.should_not be_loaded
            end
          end
        end
        
        context "by multiple ids" do
          it "removes the document from the collection" do
            model.should_delete(finder_conditions.merge(:id.in => ["first-id", "second-id"])) do
              subject.delete("first-id", "second-id")
            end
          end
          
          subject_loaded do
            it "resets the scope" do
              subject.delete("first-id", "second-id")
              subject.should_not be_loaded
            end
          end
        end
      end
      
      describe "#destroy_all" do
        let(:post1) { posts.first }
        let(:post2) { posts.last }
        
        before(:each) { model.stub_find([post1, post2]) }
        
        it "destroys all matching documents individually" do
          Post.should_delete(:id => post1.id)
          Post.should_delete(:id => post2.id)
          subject.destroy_all
        end
        
        subject_loaded do
          it "resets the scope" do
            subject.destroy_all
            subject.should_not be_loaded
          end
        end
      end
      
      describe "#destroy" do
        context "by single id" do
          let(:post) { posts.first }
          
          before(:each) { model.stub_find([post]) }
          
          it "destroys the retrieved document" do
            Post.should_delete(:id => post.id)
            subject.destroy(post.id)
          end
          
          subject_loaded do
            it "resets the scope" do
              subject.destroy(post.id)
              subject.should_not be_loaded
            end
          end
        end
        
        context "by multiple ids" do
          let(:post1) { posts.first }
          let(:post2) { posts.last }
          
          before(:each) { model.stub_find([post1, post2]) }
          
          it "destroys the documents individually" do
            Post.should_delete(:id => post1.id)
            Post.should_delete(:id => post2.id)
            subject.destroy(post1.id, post2.id)
          end
          
          subject_loaded do
            it "resets the scope" do
              subject.destroy(post1.id, post2.id)
              subject.should_not be_loaded
            end
          end
        end
      end
      
      describe "#update_all" do
        it "updates all matching documents" do
          model.should_update(finder_conditions, { :name => "New name" })
          subject.update_all(:name => "New name")
        end
        
        subject_loaded do
          it "resets the scope" do
            subject.update_all(:name => "New name")
            subject.should_not be_loaded
          end
        end
      end
      
      describe "#update" do
        context "by single id" do
          let(:post) { posts.first }
          
          it "updates the document with the given id" do
            model.should_update(finder_conditions.merge(:id => post.id), { :name => "New name" })
            subject.update(post.id, :name => "New name")
          end
          
          subject_loaded do
            it "resets the scope" do
              subject.update(post.id, {})
              subject.should_not be_loaded
            end
          end
        end
        
        context "by multiple ids" do
          let(:post1) { posts.first }
          let(:post2) { posts.last }
          
          it "updates the documents with the given ids" do
            model.should_update(finder_conditions.merge(:id.in => [post1.id, post2.id]), { :name => "New name" })
            subject.update([post1.id, post2.id], :name => "New name")
          end
          
          subject_loaded do
            it "resets the scope" do
              subject.update([post1.id, post2.id], {})
              subject.should_not be_loaded
            end
          end
        end
      end
      
      describe "#paginate" do
        it "loads the first page of results by default" do
          model.should_find(finder_options.merge(:offset => 0, :limit => 20), posts) {
            subject.paginate
          }
        end
        
        it "loads a specified page of results" do
          model.should_find(finder_options.merge(:offset => 40, :limit => 20), posts) {
            subject.paginate(:page => 3)
          }
        end
        
        it "allows the per_page option to be set" do
          model.should_find(finder_options.merge(:offset => 7, :limit => 7), posts) {
            subject.paginate(:per_page => 7, :page => 2)
          }
        end
        
        it "auto s-detect total entries where possible" do
          paginator = nil
          
          model.should_find(finder_options.merge(:offset => 0, :limit => 20), posts) {
            paginator = subject.paginate
          }
          
          paginator.total_entries.should == 5
        end
        
        it "loads total entries using count when auto-detection not possible" do
          paginator = nil
          
          subject.stub!(:count).and_return(57)
          model.should_find(finder_options.merge(:offset => 0, :limit => 5), posts) {
            paginator = subject.paginate(:per_page => 5)
          }
          
          paginator.total_entries.should == 57
        end
      end
      
      describe "#in_batches" do
        it "yields documents in groups of given size" do
          model.should_find(finder_options.merge(:offset => 0, :limit => 3), posts.first(3))
          model.should_find(finder_options.merge(:offset => 3, :limit => 3), posts.last(2))
          
          expected_size = 3
          
          subject.in_batches(3) do |docs|
            docs.size.should == expected_size
            expected_size = 2
          end
        end
      end
    end
    
    
    context "without criteria" do
      subject { basic_scope }
      
      context "when initialized" do
        it { should_not be_loaded }
      end
      
      context "when loaded" do
        before(:each) { subject.to_a }
        its(:clone) { should_not be_loaded }
      end
      
      def model
        Post
      end
      
      def finder_options
        {}
      end
      
      it_should_behave_like "all scopes"
      
      it "uses collection from class" do
        subject.collection.should == Post.collection
      end
      
      describe "#inspect" do
        before(:each) { Post.stub_find(posts) }

        it "delegates to to_a" do
          subject.inspect.should == posts.inspect
        end
      end
      
      describe "#==" do
        define_class(:NotAPost, Document)
        
        it "is equal to a new scope for the same class" do
          subject.should == Scope.new(Post)
        end

        it "is not equal to a scope for a different class" do
          subject.should_not == Scope.new(NotAPost)
        end
      end
      
      describe "#reverse_order" do
        subject { basic_scope.reverse_order }
        
        it "returns a new scope" do
          subject.should be_an_instance_of(Scope)
        end
        
        it "is not loaded" do
          basic_scope.to_a # Load parent scope
          subject.should_not be_loaded
        end
        
        it "sets the order value to descending by id" do
          subject.order_values.should == [:id.desc]
        end
      end
      
      describe "#build" do
        it "returns a new document" do
          subject.build.should be_an_instance_of(Post)
        end
        
        it "is aliased as #new" do
          subject.new(:id => '123').should == subject.build(:id => '123')
        end
      end
      
      describe "#create" do
        it "returns a new document" do
          subject.create.should be_an_instance_of(Post)
        end
        
        it "saves the document" do
          subject.create.should_not be_a_new_record
        end
      end
      
      describe "#apply_finder_options" do
        it "returns a new scope" do
          subject.apply_finder_options({}).should be_an_instance_of(Scope)
        end
        
        it "sets where values from options" do
          scope = subject.apply_finder_options({ :conditions => { :author => "John" } })
          scope.where_values.should == [{ :author => "John" }]
        end
        
        it "sets order values from options" do
          scope = subject.apply_finder_options({ :order => :author.desc })
          scope.order_values.should == [:author.desc]
        end
        
        it "sets select values from options" do
          scope = subject.apply_finder_options({ :select => [:id, :author] })
          scope.select_values.should == [:id, :author]
        end
        
        it "sets offset value from options" do
          scope = subject.apply_finder_options({ :offset => 40 })
          scope.offset_value.should == 40
        end
        
        it "sets limit value from options" do
          scope = subject.apply_finder_options({ :limit => 50 })
          scope.limit_value.should == 50
        end
      end
    end

    
    context "with criteria" do
      define_class(:OtherPost, Document)
      
      let(:timestamp) { Time.now }
      let(:scoped) do
        basic_scope.where(:author => "Sam").
                    where(:published => true).
                    where(:date.lt => timestamp).
                    order(:author.asc).
                    order(:published.desc).
                    select(:author).
                    select(:published).
                    offset(15).
                    limit(7).
                    from(OtherPost.collection)
      end
      
      subject { scoped }
      
      def truncate_timestamp(time)
        time.change(:usec => (time.usec / 1000.0).floor * 1000)
      end
      
      def model
        OtherPost
      end
      
      def finder_options
        {
          :conditions => { "author" => "Sam", "published" => true, "date" => { "$lt" => truncate_timestamp(timestamp.utc) } },
          :order => [:author.asc, :published.desc],
          :select => [:author, :published],
          :offset => 15,
          :limit => 7
        }
      end
      
      it_should_behave_like "all scopes"
      
      describe "#build" do
        it "uses equality where conditions as attributes" do
          doc = subject.build
          doc.author.should == "Sam"
          doc.published.should be_true
          doc.date.should be_nil
        end
      end
      
      describe "#create" do
        it "uses equality where conditions as attributes" do
          doc = subject.create
          doc.author.should == "Sam"
          doc.published.should be_true
          doc.date.should be_nil
        end
      end
      
      describe "#reverse_order" do
        subject { scoped.reverse_order }
        
        it "sets the order values to the reverse order" do
          subject.order_values.should == MongoOrder.parse([:author.desc, :published.asc]).to_a
        end
      end
      
      describe "#except" do
        context "given :where" do
          it "returns a new scope without where values" do
            s = subject.except(:where)
            s.where_values.should be_empty
            s.order_values.should == [:author.asc, :published.desc]
            s.select_values.should == [:author, :published]
            s.offset_value.should == 15
            s.limit_value.should == 7
            s.collection.should == OtherPost.collection
          end
        end

        context "given :order" do
          it "returns a new scope without order values" do
            s = subject.except(:order)
            s.where_values.should == [{ :author => "Sam" }, { :published => true }, { :date.lt => timestamp }]
            s.order_values.should be_empty
            s.select_values.should == [:author, :published]
            s.offset_value.should == 15
            s.limit_value.should == 7
            s.collection.should == OtherPost.collection
          end
        end

        context "given :select" do
          it "returns a new scope without select values" do
            s = subject.except(:select)
            s.where_values.should == [{ :author => "Sam" }, { :published => true }, { :date.lt => timestamp }]
            s.order_values.should == [:author.asc, :published.desc]
            s.select_values.should be_empty
            s.offset_value.should == 15
            s.limit_value.should == 7
            s.collection.should == OtherPost.collection
          end
        end

        context "given :offset" do
          it "returns a new scope without offset value" do
            s = subject.except(:offset)
            s.where_values.should == [{ :author => "Sam" }, { :published => true }, { :date.lt => timestamp }]
            s.order_values.should == [:author.asc, :published.desc]
            s.select_values.should == [:author, :published]
            s.offset_value.should be_nil
            s.limit_value.should == 7
            s.collection.should == OtherPost.collection
          end
        end

        context "given :limit" do
          it "returns a new scope without limit value" do
            s = subject.except(:limit)
            s.where_values.should == [{ :author => "Sam" }, { :published => true }, { :date.lt => timestamp }]
            s.order_values.should == [:author.asc, :published.desc]
            s.select_values.should == [:author, :published]
            s.offset_value.should == 15
            s.limit_value.should be_nil
            s.collection.should == OtherPost.collection
          end
        end

        context "given :from" do
          it "returns a new scope with default collection" do
            s = subject.except(:from)
            s.where_values.should == [{ :author => "Sam" }, { :published => true }, { :date.lt => timestamp }]
            s.order_values.should == [:author.asc, :published.desc]
            s.select_values.should == [:author, :published]
            s.offset_value.should == 15
            s.limit_value.should == 7
            s.collection.should == Post.collection
          end
        end
      end
      
      describe "#merge" do
        let(:on_load_proc) { proc {} }
        let(:merged) do
          basic_scope.where(:date.gt => timestamp-1.year).
                      order(:date.desc).
                      select(:date).
                      on_load(&on_load_proc)
        end
        let(:result) { subject.merge(merged) }
        
        it "combines where values from scopes" do
          result.where_values.should == [
            { :author => "Sam" },
            { :published => true },
            { :date.lt => timestamp },
            { :date.gt => timestamp-1.year }
          ]
        end
        
        it "combines order values from scopes" do
          result.order_values.should == [:author.asc, :published.desc, :date.desc]
        end
        
        it "combines select values from scopes" do
          result.select_values.should == [:author, :published, :date]
        end
        
        it "preserves on load proc" do
          result.on_load_proc.should == on_load_proc
        end
        
        context "merged scope has offset value" do
          let(:merged) { basic_scope.offset(10) }
          
          it "uses offset value from merged scope" do
            result.offset_value.should == 10
          end
        end
        
        context "merged scope has no offset value set" do
          let(:merged) { basic_scope }
          
          it "uses offset value from original scope" do
            result.offset_value.should == 15
          end
        end
        
        context "merged scope has limit value" do
          let(:merged) { basic_scope.limit(50) }
          
          it "uses limit value from merged scope" do
            result.limit_value.should == 50
          end
        end
        
        context "merged scope has no limit value set" do
          let(:merged) { basic_scope }
          
          it "uses limit value from original scope" do
            result.limit_value.should == 7
          end
        end
        
        it "uses from value (collection) from merged scope" do
          merged = basic_scope.from(Post.collection)
          subject.merge(merged).collection.should == Post.collection
        end
      end
    end
  end
end
