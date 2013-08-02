require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    define_class(:TestModel, described_class) do
      property :name, String
      property :age, Integer
      property :paid, Boolean
      property :prefs, Hash
      property :internal, String, :internal => true
      
      def hello
        "Hi friend!"
      end
    end
    
    let(:instance) do
      TestModel.new(:id => "abc-123", :name => 'Hello World', :age => 25, :paid => true, :prefs => { :foo => 'bar' }, :internal => 'hideme')
    end
    
    it "includes root in json" do
      begin
        TestModel.include_root_in_json = true
        
        json = instance.to_json
        json.should match(/^\{"test_model":\{/)
      ensure
        TestModel.include_root_in_json = false
      end
    end
    
    it "encodes all public attributes" do
      json = instance.to_json
      json.should match(/"name":"Hello World"/)
      json.should match(/"age":25/)
      json.should match(/"paid":true/)
      json.should match(/"prefs":\{"foo":"bar"\}/)
    end
    
    if described_class == Document
      it "encodes the id" do
        json = instance.to_json
        json.should match(/"id":"abc-123"/)
      end
    end
    
    it "does not encode internal attributes" do
      json = instance.to_json
      json.should_not match(/"internal":"hideme"/)
    end
    
    it "allows attribute filtering with only" do
      json = instance.to_json(:only => [:name, :age])
      json.should match(/"name":"Hello World"/)
      json.should match(/"age":25/)
      json.should_not match(/"paid":true/)
      json.should_not match(/"prefs":\{"foo":"bar"\}/)
    end
    
    it "allows attribute filtering with except" do
      json = instance.to_json(:except => [:name, :age])
      json.should_not match(/"name":"Hello World"/)
      json.should_not match(/"age":25/)
      json.should match(/"paid":true/)
      json.should match(/"prefs":\{"foo":"bar"\}/)
    end
    
    it "allows methods to be included" do
      json = instance.to_json(:methods => [:hello, :type])
      json.should match(/"hello":"Hi friend!"/)
      json.should match(/"type":"TestModel"/)
    end
  end
end
