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
    end
    
    describe "#scope" do
      it "should create a method returning the scope" do
        Post.class_eval do
          scope :published, where(:published => true)
        end
        
        Post.published.should be_an_instance_of(MongoModel::Scope)
        Post.published.where_values.should == [{:published => true}]
      end
      
      it "should allow existing scopes to be built upon" do
        Post.class_eval do
          scope :recent, order(:created_at.desc).limit(5)
          scope :recently_published, recent.where(:published => true)
        end
        
        Post.recently_published.where_values.should == [{:published => true}]
        Post.recently_published.order_values.should == [:created_at.desc]
        Post.recently_published.limit_value.should == 5
      end
    end
  end
end
