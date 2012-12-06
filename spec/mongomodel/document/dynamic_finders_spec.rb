require 'spec_helper'

module MongoModel
  specs_for(Document) do
    describe "dynamic finders" do
      define_class(:Person, Document) do
        property :name, String
        property :age, Integer
      end
      
      subject { Person }
      
      before(:each) do
        @john = Person.create!(:name => 'John', :age => 42, :id => '1')
        @young_john = Person.create!(:name => 'John', :age => 12, :id => '2')
        @tom1 = Person.create!(:name => 'Tom', :age => 23, :id => '3')
        @tom2 = Person.create!(:name => 'Tom', :age => 23, :id => '4')
        @mary = Person.create!(:name => 'Mary', :age => 33, :id => '5')
      end
      
      def self.should_find(*args, &block)
        it "returns correct results when called with #{args.inspect}" do
          expected = instance_eval(&block)
          subject.send(valid_finder, *args).should == expected
        end
      end
      
      def self.should_raise(*args, &block)
        it "raises DocumentNotFound exception if results not found" do
          message = instance_eval(&block)
          lambda { subject.send(valid_finder, *args) }.should raise_error(DocumentNotFound, message)
        end
      end
      
      def self.should_initialize(*args, &block)
        it "initializes new instance" do
          result = subject.send(valid_finder, *args)
          result.should be_a_new_record
          result.should be_an_instance_of(Person)
          yield(result).should be_true
        end
      end
      
      def self.should_create(*args, &block)
        it "creates new instance" do
          result = subject.send(valid_finder, *args)
          result.should_not be_a_new_record
          result.should be_an_instance_of(Person)
          yield(result).should be_true
        end
      end
      
      shared_examples_for "a dynamic finder" do
        it { should respond_to(valid_finder) }
        it { should_not respond_to(invalid_finder) }
        
        it "raises NoMethodError calling an invalid finder" do
          lambda { subject.send(invalid_finder, "Foo") }.should raise_error(NoMethodError)
        end
      end
      
      describe "find first by single property" do
        let(:valid_finder) { :find_by_name }
        let(:invalid_finder) { :find_by_something_else }
        
        it_should_behave_like "a dynamic finder"
        
        should_find("John") { @john }
        should_find("Jane") { nil }
      end
      
      describe "find first by single property (bang method)" do
        let(:valid_finder) { :find_by_name! }
        let(:invalid_finder) { :find_by_something_else! }
        
        it_should_behave_like "a dynamic finder"
        
        should_find("John") { @john }
        should_raise("Jane") { 'Couldn\'t find Person with {:name=>"Jane"}' }
      end
      
      describe "find last by single property" do
        let(:valid_finder) { :find_last_by_name }
        let(:invalid_finder) { :find_last_by_something_else }
        
        it_should_behave_like "a dynamic finder"
        
        should_find("John") { @young_john }
        should_find("Jane") { nil }
      end
      
      describe "find all by single property" do
        let(:valid_finder) { :find_all_by_name }
        let(:invalid_finder) { :find_all_by_something_else }
        
        it_should_behave_like "a dynamic finder"
        
        should_find("John") { [@john, @young_john] }
      end
      
      describe "find first by multiple properties" do
        let(:valid_finder) { :find_by_name_and_age }
        let(:invalid_finder) { :find_by_age_and_something_else }
        
        it_should_behave_like "a dynamic finder"
        
        should_find("Tom", 23) { @tom1 }
        should_find("Tom", 5) { nil }
      end
      
      describe "find first by multiple properties (bang method)" do
        let(:valid_finder) { :find_by_name_and_age! }
        let(:invalid_finder) { :find_by_age_and_something_else! }
        
        it_should_behave_like "a dynamic finder"
        
        should_find("Tom", 23) { @tom1 }
        should_raise("Tom", 5) { "Couldn\'t find Person with #{{:name=>"Tom", :age=>5}.inspect}" }
      end
      
      describe "find all by multiple properties" do
        let(:valid_finder) { :find_all_by_name_and_age }
        let(:invalid_finder) { :find_all_by_age_and_something_else }
        
        it_should_behave_like "a dynamic finder"
        
        should_find("Tom", 23) { [@tom1, @tom2] }
        should_find("Tom", 5) { [] }
      end
      
      describe "find last by multiple properties" do
        let(:valid_finder) { :find_last_by_name_and_age }
        let(:invalid_finder) { :find_last_by_age_and_something_else }
        
        it_should_behave_like "a dynamic finder"
        
        should_find("Tom", 23) { @tom2 }
        should_find("Tom", 5) { nil }
      end
      
      describe "find or initialize by single property" do
        let(:valid_finder) { :find_or_initialize_by_name }
        let(:invalid_finder) { :find_or_initialize_by_something_else }
        
        it_should_behave_like "a dynamic finder"
        
        should_find("John") { @john }
        should_initialize("Jane") { |p| p.name == "Jane" }
      end
      
      describe "find or initialize by multiple properties" do
        let(:valid_finder) { :find_or_initialize_by_name_and_age }
        let(:invalid_finder) { :find_or_initialize_by_name_and_something_else }
        
        it_should_behave_like "a dynamic finder"
        
        should_find("John", 42) { @john }
        should_initialize("John", 1) { |p| p.name == "John" && p.age == 1 }
      end
      
      describe "find or create by single property" do
        let(:valid_finder) { :find_or_create_by_name }
        let(:invalid_finder) { :find_or_create_by_something_else }
        
        it_should_behave_like "a dynamic finder"
        
        should_find("John") { @john }
        should_create("Jane") { |p| p.name == "Jane" }
      end
      
      describe "find or create by multiple properties" do
        let(:valid_finder) { :find_or_create_by_name_and_age }
        let(:invalid_finder) { :find_or_create_by_name_and_something_else }
        
        it_should_behave_like "a dynamic finder"
        
        should_find("John", 42) { @john }
        should_create("John", 1) { |p| p.name == "John" && p.age == 1 }
      end
    end
  end
end
