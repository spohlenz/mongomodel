require 'spec_helper'

module MongoModel
  describe Document do
    define_class(:Post, Document)
    
    describe "#scoped" do
      subject { Post.scoped }
      
      it { should be_an_instance_of(MongoModel::Scope) }
      
      it "should set the target class" do
        subject.klass.should == Post
      end
      
      context "with default scope(s) set" do
        define_class(:Post, Document) do
          default_scope order(:title.asc)
          default_scope limit(5)
        end
        
        it "should return the default scope" do
          scope = Post.scoped
          scope.order_values.should == [:title.asc]
          scope.limit_value.should == 5
        end
      end
      
      context "within a with_scope block" do
        it "should return the current scope" do
          Post.class_eval do
            with_scope(where(:published => true)) do
              scoped.where_values.should == [{:published => true}]
            end
          end
        end
      end
      
      context "within nested with_scope blocks" do
        it "should return the merged scope" do
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
      it "should create a method returning the scope" do
        Post.class_eval do
          scope :published, where(:published => true)
        end
        
        scope = Post.published
        scope.should be_an_instance_of(MongoModel::Scope)
        scope.where_values.should == [{:published => true}]
      end
      
      it "should create parameterized method returning the scope when given a lambda" do
        Post.class_eval do
          scope :latest, lambda { |num| order(:created_at.desc).limit(num) }
        end
        
        scope = Post.latest(4)
        scope.order_values.should == [:created_at.desc]
        scope.limit_value.should == 4
      end
      
      it "should allow existing scopes to be built upon" do
        Post.class_eval do
          scope :recent, order(:created_at.desc).limit(5)
          scope :recently_published, recent.where(:published => true)
        end
        
        scope = Post.recently_published
        scope.where_values.should == [{:published => true}]
        scope.order_values.should == [:created_at.desc]
        scope.limit_value.should == 5
      end
    end
    
    describe "named scopes" do
      define_class(:Post, Document) do
        scope :published, where(:published => true)
        scope :recent, order(:created_at.desc).limit(5)
      end
      
      it "should be chainable" do
        scope = Post.published.recent
        scope.where_values.should == [{:published => true}]
        scope.order_values.should == [:created_at.desc]
        scope.limit_value.should == 5
      end
    end
  end
end
