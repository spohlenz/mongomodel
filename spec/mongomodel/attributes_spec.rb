require 'spec_helper'
require 'active_support/hash_with_indifferent_access'

module MongoModel
  describe Document do
    AttributeTypes = {
      String => "my string",
      Integer => 99,
      Float => 45.123,
      Symbol => :foobar,
      Boolean => false,
      Array => [ 1, 2, 3, "hello", :world, [99, 100] ],
      Hash => ActiveSupport::HashWithIndifferentAccess.new({ :rabbit => 'hat', 'hello' => 12345 }),
      Date => lambda { Date.today },
      Time => lambda { Time.now }
    }
    
    AttributeTypes.each do |type, value|
      describe "setting #{type} attributes" do
        define_class(:TestDocument, Document) do
          property :test_property, type
        end
      
        before(:each) do
          @value = value.respond_to?(:call) ? value.call : value
        end
      
        subject { TestDocument.create!(:test_property => @value) }
      
        it "should read the correct value from attributes" do
          subject.test_property.should == @value
        end
      
        it "should read the correct value after reloading" do
          TestDocument.find(subject.id).test_property.should == subject.test_property
        end
      end
    end
  end
end
