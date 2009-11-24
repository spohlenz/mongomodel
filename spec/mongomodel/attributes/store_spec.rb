require 'spec_helper'

module MongoModel::Attributes
  describe Store do
    class CustomClass
      attr_reader :name
      
      def initialize(name)
        @name = name
      end
      
      def ==(other)
        other.is_a?(self.class) && name == other.name
      end
      
      def to_mongo
        { :name => name }
      end
      
      def self.from_mongo(mongo)
        mongo[:name]
      end
      
      def self.cast(value)
        new(value.to_s)
      end
    end
    
    def properties
      properties = ActiveSupport::OrderedHash.new
      properties[:string]  = MongoModel::Properties::Property.new(:string, String)
      properties[:integer] = MongoModel::Properties::Property.new(:integer, Integer)
      properties[:float]   = MongoModel::Properties::Property.new(:float, Float)
      properties[:boolean] = MongoModel::Properties::Property.new(:boolean, Boolean)
      properties[:symbol]  = MongoModel::Properties::Property.new(:symbol, Symbol)
      properties[:hash]    = MongoModel::Properties::Property.new(:hash, Hash)
      properties[:array]   = MongoModel::Properties::Property.new(:array, Array)
      properties[:date]    = MongoModel::Properties::Property.new(:date, Date)
      properties[:time]    = MongoModel::Properties::Property.new(:time, Time)
      properties[:custom]  = MongoModel::Properties::Property.new(:custom, CustomClass)
      properties[:default] = MongoModel::Properties::Property.new(:default, String, :default => 'Default')
      properties[:as]      = MongoModel::Properties::Property.new(:as, String, :as => '_custom_as')
      properties
    end
    
    subject { Store.new(properties) }
    
    it "should set default property values" do
      subject.set_defaults!(mock('document instance'))
      subject.keys.should == properties.keys
      subject[:default].should == 'Default'
    end
    
    describe "setting to nil" do
      specify "all property types should be nullable" do
        properties.keys.each do |property|
          subject[property] = nil
          subject[property].should be_nil
        end
      end
    end
    
    it "should set attributes that aren't properties" do
      subject[:non_property] = "Hello World"
      subject[:non_property].should == "Hello World"
    end
    
    describe "type-casting" do
      TypeCastExamples = {
        :string =>
          {
            "abc" => "abc",
            123   => "123"
          },
        :integer =>
          {
            123      => 123,
            55.123   => 55,
            "999"    => 999,
            "12.123" => 12
          },
        :float =>
          {
            55.123   => 55.123,
            123      => 123.0,
            "12.123" => 12.123
          },
        :boolean =>
          {
            true    => true,
            false   => false,
            "true"  => true,
            "false" => false,
            1       => true,
            0       => false,
            "1"     => true,
            "0"     => false,
            ''      => nil
          },
        :symbol =>
          {
            :some_symbol  => :some_symbol,
            "some_string" => :some_string
          },
        :hash =>
          {
            { :foo => 'bar' } => { :foo => 'bar' }
          },
        :array =>
          {
            [123, 'abc', :foo, true] => [123, 'abc', :foo, true]
          },
        :date =>
          {
            Date.civil(2009, 11, 15)             => Date.civil(2009, 11, 15),
            Time.local(2008, 12, 3, 0, 0, 0, 0)  => Date.civil(2008, 12, 3),
            "2009/3/4"                           => Date.civil(2009, 3, 4),
            "Sat Jan 01 20:15:01 UTC 2000"       => Date.civil(2000, 1, 1)
          },
        :time =>
          {
            Time.local(2008, 5, 14, 1, 2, 3, 4) => Time.local(2008, 5, 14, 1, 2, 3, 4),
            Date.civil(2009, 11, 15)            => Time.local(2009, 11, 15, 0, 0, 0, 0),
            "Sat Jan 01 20:15:01 UTC 2000"      => Time.utc(2000, 1, 1, 20, 15, 1, 0),
            "2009/3/4"                          => Time.utc(2009, 3, 4, 0, 0, 0, 0)
          }
      }
      
      TypeCastExamples.each do |type, examples|
        context "assigning to #{type} property" do
          examples.each do |assigned, expected|
            it "should cast #{assigned.inspect} to #{expected.inspect}" do
              subject[type] = assigned
              subject[type].should == expected
            end
          end
        end
      end
      
      context "assigning to custom property" do
        before(:each) do
          @custom = CustomClass.new('instance name')
        end
        
        it "should not alter instances of CustomClass" do
          subject[:custom] = @custom
          subject[:custom].should == @custom
        end
        
        it "should cast strings to CustomClass" do
          subject[:custom] = "foobar"
          subject[:custom].should == CustomClass.new('foobar')
        end
      end
    end
    
    describe "#before_type_cast" do
      BeforeTypeCastExamples = {
        :string => [ "abc", 123 ],
        :integer => [ 123, 55.123, "999", "12.123" ],
        :float => [ 55.123, 123, "12.123" ],
        :boolean => [ true, false, "true", "false", 1, 0, "1", "0", '' ],
        :symbol => [ :some_symbol, "some_string" ],
        :hash => [ { :foo => 'bar' } ],
        :array => [ [123, 'abc', :foo, true] ],
        :date => [ Date.civil(2009, 11, 15), Time.local(2008, 12, 3, 0, 0, 0, 0), "2009/3/4", "Sat Jan 01 20:15:01 UTC 2000" ],
        :time => [ Time.local(2008, 5, 14, 1, 2, 3, 4), Date.civil(2009, 11, 15), "Sat Jan 01 20:15:01 UTC 2000", "2009/3/4" ]
      }
      
      BeforeTypeCastExamples.each do |type, examples|
        context "assigning to #{type} property" do
          examples.each do |example|
            it "should access pre-typecasted value of #{example.inspect}" do
              subject[example] = example
              subject.before_type_cast(example).should == example
            end
          end
        end
      end
    end
    
    describe "serialization" do
      it "should convert to mongo representation" do
        subject[:string] = 'string'
        subject[:integer] = 42
        subject[:float] = 123.45
        subject[:boolean] = false
        subject[:symbol] = :symbol
        subject[:hash] = { :foo => 'bar', :custom => CustomClass.new('custom in hash') }
        subject[:array] = [ 123, 'abc', 45.67, true, :bar, CustomClass.new('custom in array') ]
        subject[:date] = Date.civil(2009, 11, 15)
        subject[:time] = Time.local(2008, 5, 14, 1, 2, 3, 4)
        subject[:custom] = CustomClass.new('custom')
        subject[:as] = "As property"
        subject[:non_property] = "Hello World"
        subject[:custom_non_property] = CustomClass.new('custom non property')
        
        subject.to_mongo.should == {
          'string' => 'string',
          'integer' => 42,
          'float' => 123.45,
          'boolean' => false,
          'symbol' => :symbol,
          'hash' => { :foo => 'bar', :custom => { :name => 'custom in hash' } },
          'array' => [ 123, 'abc', 45.67, true, :bar, { :name => 'custom in array' } ],
          'date' => Date.civil(2009, 11, 15),
          'time' => Time.local(2008, 5, 14, 1, 2, 3, 4),
          'custom' => { :name => 'custom' },
          '_custom_as' => "As property",
          'non_property' => "Hello World",
          'custom_non_property' => { :name => 'custom non property' },
        }
      end
      
      it "should load from mongo representation" do
        subject.from_mongo!({
          'string' => 'string',
          'integer' => 42,
          'float' => 123.45,
          'boolean' => false,
          'symbol' => :symbol,
          'hash' => { :foo => 'bar' },
          'array' => [ 123, 'abc', 45.67, true, :bar ],
          'date' => Date.civil(2009, 11, 15),
          'time' => Time.local(2008, 5, 14, 1, 2, 3, 4),
          'custom' => { :name => 'custom' },
          '_custom_as' => "As property",
          'custom_non_property' => { :name => 'custom non property' }
        })
        
        subject[:string].should == 'string'
        subject[:integer].should == 42
        subject[:float].should == 123.45
        subject[:boolean].should == false
        subject[:symbol].should == :symbol
        subject[:hash].should == { :foo => 'bar' }
        subject[:array].should == [ 123, 'abc', 45.67, true, :bar ]
        subject[:date].should == Date.civil(2009, 11, 15)
        subject[:time].should == Time.local(2008, 5, 14, 1, 2, 3, 4)
        subject[:custom].should == CustomClass.new('custom')
        subject[:as].should == "As property"
        subject[:custom_non_property].should == { :name => 'custom non property' }
      end
    end
  end
end