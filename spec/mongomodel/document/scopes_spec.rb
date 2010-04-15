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
  end
end
