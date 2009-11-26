require 'spec_helper'

module MongoModel
  describe EmbeddedDocument do
    define_class(:TestDocument, EmbeddedDocument) do
      property :foo, Date
    end
    
    subject { TestDocument.new }
    
    describe "#read_attribute_before_type_cast" do
      context "with property" do
        it "should return the attribute before type casting" do
          subject.attributes[:foo] = 'some date'
          subject.read_attribute_before_type_cast(:foo).should == 'some date'
        end
        
        it "should define a reader method" do
          subject.attributes[:foo] = 'some date'
          subject.foo_before_type_cast.should == 'some date'
        end
      end
      
      context "no property" do
        it "should return the attribute without type casting" do
          subject.attributes[:bar] = 'set bar'
          subject.read_attribute_before_type_cast(:bar).should == 'set bar'
        end
        
        it "should not define a reader method" do
          lambda { subject.bar_before_type_cast }.should raise_error(NoMethodError)
        end
      end
    end
    
    describe "#attributes_before_type_cast" do
      it "should return a hash of attributes before type casting" do
        subject.attributes[:foo] = 'some date'
        subject.attributes[:bar] = 'set bar'
        
        subject.attributes_before_type_cast.should == {
          :foo => 'some date', :bar => 'set bar'
        }
      end
    end
  end
end
