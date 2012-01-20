require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    describe "generating attribute methods" do
      define_class(:TestDocument, described_class) do
        property :foo, String
        
        def foo(a); "from method"; end
      end
      
      subject { TestDocument.new }
      
      it "should not overwrite an existing method" do
        subject.foo(1).should == "from method"
      end
      
      context "on a subclass" do
        define_class(:SubDocument, :TestDocument)
        subject { SubDocument.new }
      
        it "should not overwrite methods defined on the superclass" do
          subject.foo(1).should == "from method"
        end
      end
      
      context "on a class with an included module" do
        module TestModule
          def foo(a); "from method"; end
        end
        
        it "should not overwrite methods defined on the included module" do
          TestDocument.send(:include, TestModule)
          subject.foo(1).should == "from method"
        end
      end
      
      context "on a class with an included concern that defines the property" do
        module TestConcern
          extend ActiveSupport::Concern
          
          included do
            property :bar, String
          end
          
          def bar(a); "from concern"; end
        end
        
        context "the base class" do
          it "should not overwrite methods defined within the concern" do
            TestDocument.send(:include, TestConcern)
            subject.bar(1).should == "from concern"
          end
        end
        
        context "subclasses" do
          define_class(:SubDocument, :TestDocument)
          subject { SubDocument.new }
          
          it "should not overwrite methods defined within the concern" do
            SubDocument.send(:include, TestConcern)
            subject.bar(1).should == "from concern"
          end
        end
      end
    end
  end
end
