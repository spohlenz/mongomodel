require 'spec_helper'

module MongoModel
  module Properties
    describe Property do
      context "no options" do
        subject { Property.new(:name, String) }
    
        it "should set property name" do
          subject.name.should == :name
        end
      
        it "should set property type" do
          subject.type.should == String
        end
      
        it "should set default as value from name" do
          subject.as.should == 'name'
        end
      
        it "should default to nil" do
          subject.default(mock('document instance')).should be_nil
        end
      
        it "should equal a property with the same name and type" do
          subject.should == Property.new(:name, String)
        end
      
        it "should not equal properties with different name, type and options" do
          subject.should_not == Property.new(:address, String)
          subject.should_not == Property.new(:name, Float)
          subject.should_not == Property.new(:name, String, :default => 'Anonymous')
        end
        
        it { should_not be_internal }
      end
    
      context "with options" do
        subject { Property.new(:age, Integer, :as => '_record_age', :default => 21) }
      
        it "should set property options" do
          subject.options.should == { :as => '_record_age', :default => 21 }
        end
      
        it "should set custom as value" do
          subject.as.should == '_record_age'
        end
      
        it "should default to custom default" do
          subject.default(mock('document instance')).should == 21
        end
      
        it "should equal a property with the same name, type and options" do
          subject.should == Property.new(:age, Integer, :as => '_record_age', :default => 21)
        end
      
        it "should not equal properties with different name, type and options" do
          subject.should_not == Property.new(:address, String)
          subject.should_not == Property.new(:name, Float)
          subject.should_not == Property.new(:name, String, :default => 'Anonymous')
        end
      
        context "with callable default" do
          subject { Property.new(:age, Integer, :default => lambda { |doc| doc.answer }) }

          it "should call lambda with given instance" do
            subject.default(mock('document instance', :answer => 42)).should == 42
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
    end
  end
end
