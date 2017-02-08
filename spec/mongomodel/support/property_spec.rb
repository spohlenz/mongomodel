require 'spec_helper'

module MongoModel
  module Properties
    describe Property do
      context "no options" do
        subject { Property.new(:name, String) }
    
        it "sets property name" do
          subject.name.should == :name
        end
      
        it "sets property type" do
          subject.type.should == String
        end
      
        it "sets default as value from name" do
          subject.as.should == 'name'
        end
      
        it "defaults to nil" do
          subject.default(double('document instance')).should be_nil
        end
      
        it "equals a property with the same name and type" do
          subject.should == Property.new(:name, String)
        end
      
        it "does not equal properties with different name, type and options" do
          subject.should_not == Property.new(:address, String)
          subject.should_not == Property.new(:name, Float)
          subject.should_not == Property.new(:name, String, :default => 'Anonymous')
        end
        
        it { should_not be_internal }
      end
    
      context "with options" do
        subject { Property.new(:age, Integer, :as => '_record_age', :default => 21) }
      
        it "sets property options" do
          subject.options.should == { :as => '_record_age', :default => 21 }
        end
      
        it "sets custom as value" do
          subject.as.should == '_record_age'
        end
      
        it "defaults to custom default" do
          subject.default(double('document instance')).should == 21
        end
      
        it "equals a property with the same name, type and options" do
          subject.should == Property.new(:age, Integer, :as => '_record_age', :default => 21)
        end
      
        it "does not equal properties with different name, type and options" do
          subject.should_not == Property.new(:address, String)
          subject.should_not == Property.new(:name, Float)
          subject.should_not == Property.new(:name, String, :default => 'Anonymous')
        end
      
        context "with callable default" do
          let(:document) { double('document instance', :answer => 42) }
          
          it "calls the proc yielding the instance" do
            property = Property.new(:age, Integer, :default => lambda { |doc| doc.answer })
            property.default(document).should == 42
          end
          
          it "calls the proc in the context of the instance" do
            property = Property.new(:age, Integer, :default => proc { answer })
            property.default(document).should == 42
          end
        end
        
        context "with internal option" do
          subject { Property.new(:age, Integer, :internal => true) }
          it { should be_internal }
        end
        
        context "with internal property name" do
          subject { Property.new(:age, Integer, :as => '_age') }
          it { should be_internal }
        end
      end
      
      it "does not validate if options[:validate] is false" do
        Property.new(:age, Integer, :validate => false).validate?.should be false
      end
      
      it "validates when options[:validate] is true or not provided" do
        Property.new(:age, Integer, :validate => true).validate?.should be true
        Property.new(:age, Integer).validate?.should be true
      end

      context "with type Integer" do
        it "correctly converts type from mongo representation" do
          Property.new(:age, Integer).from_mongo(15.0).should be_a_kind_of(Integer)
        end
      end
    end
  end
end
