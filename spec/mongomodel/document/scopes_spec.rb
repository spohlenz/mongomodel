require 'spec_helper'

module MongoModel
  describe Document do
    define_class(:Post, Document)
    
    describe "#scoped" do
      subject { Post.scoped }
      
      it { should be_an_instance_of(MongoModel::Scope) }
      
      it "sets the target class" do
        subject.klass.should == Post
      end
      
      context "with default scope(s) set" do
        define_class(:Post, Document) do
          default_scope order(:title.asc)
          default_scope limit(5)
        end
        
        it "returns the default scope" do
          scope = Post.scoped
          scope.order_values.should == [:title.asc]
          scope.limit_value.should == 5
        end
      end
      
      context "within a with_scope block" do
        it "returns the current scope" do
          Post.class_eval do
            with_scope(where(:published => true)) do
              scoped.where_values.should == [{:published => true}]
            end
          end
        end
      end
      
      context "within nested with_scope blocks" do
        it "returns the merged scope" do
          Post.class_eval do
            with_scope(where(:published => true)) do
              with_scope(limit(5)) do
                scoped.where_values.should == [{:published => true}]
                scoped.limit_value.should == 5
              end
            end
          end
        end
      end
    end
    
    describe "#scope" do
      define_class(:Post, Document) do
        scope :published, where(:published => true)
        
        scope :latest, lambda { |num| order(:created_at.desc).limit(num) }
        
        scope :recent, order(:created_at.desc).limit(5)
        scope :recently_published, recent.where(:published => true)
      end
      
      define_class(:SpecialPost, :Post)
      
      it "creates a method returning the scope" do
        scope = Post.published
        scope.should be_an_instance_of(MongoModel::Scope)
        scope.where_values.should == [{:published => true}]
      end
      
      it "creates parameterized method returning the scope when given a lambda" do
        scope = Post.latest(4)
        scope.order_values.should == [:created_at.desc]
        scope.limit_value.should == 4
      end
      
      it "allows existing scopes to be built upon" do
        scope = Post.recently_published
        scope.where_values.should == [{:published => true}]
        scope.order_values.should == [:created_at.desc]
        scope.limit_value.should == 5
      end
      
      it "merges the scope with the current scope of the class it is called upon" do
        scope = SpecialPost.published
        scope.klass.should == SpecialPost
      end
    end
    
    describe "named scopes" do
      define_class(:Post, Document) do
        scope :published, where(:published => true)
        scope :recent, order(:created_at.desc).limit(5)
      end
      
      it "is chainable" do
        scope = Post.published.recent
        scope.where_values.should == [{:published => true}]
        scope.order_values.should == [:created_at.desc]
        scope.limit_value.should == 5
      end
    end
  end
end
