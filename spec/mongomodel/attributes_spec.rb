require 'spec_helper'
require 'active_support/core_ext/hash/indifferent_access'

module MongoModel
  describe Document do
    AttributeTypes = {
      String => "my string",
      Integer => 99,
      Float => 45.123,
      Symbol => :foobar,
      Boolean => false,
      Array => [ 1, 2, 3, "hello", :world, [99, 100] ],
      Hash => { :rabbit => 'hat', 'hello' => 12345 }.with_indifferent_access,
      Date => lambda { Date.today },
      Time => lambda { Time.now },
      CustomClass => CustomClass.new('hello')
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
    
    describe "setting attributes with hash" do
      define_class(:TestDocument, Document) do
        property :test_property, String
        
        def test_property=(value)
          write_attribute(:test_property, 'set from method')
        end
      end
      
      subject { TestDocument.new }
      
      it "should call custom property methods" do
        subject.attributes = { :test_property => 'property value' }
        subject.test_property.should == 'set from method'
      end
      
      it "should use write_attribute if no such property" do
        subject.attributes = { :non_property => 'property value' }
        subject.read_attribute(:non_property).should == 'property value'
      end
    end
  end
end
