require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    shared_examples_for "ActiveModel" do
      require 'minitest'
      require 'minitest/assertions'
      include Minitest::Assertions
      
      attr_accessor :assertions
      before(:all) { self.assertions = 0 }

      include ActiveModel::Lint::Tests

      ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
        example m.gsub('_',' ') do
          send m
        end
      end

      let(:model) { subject }
    end
    
    define_class(:TestModel, described_class)
    subject { TestModel.new }
        
    it_should_behave_like "ActiveModel"
  end
end
