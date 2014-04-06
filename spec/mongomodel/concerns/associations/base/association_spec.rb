require 'spec_helper'

module MongoModel
  module Associations
    module Base
      describe Association do
        define_class(:Chapter, MongoModel::Document)
        define_class(:IllustratedChapter, :Chapter)
        define_class(:NonChapter, MongoModel::Document)
        
        let(:klass) { Chapter }
        let(:definition) { double(:klass => klass) }
        let(:instance) { double }
        
        subject! { Association.new(definition, instance) }
    
        describe "#ensure_class" do
          it "accepts instances of the definition class" do
            subject.ensure_class(Chapter.new)
          end
          
          it "accepts instances of a subclass of the definition class" do
            subject.ensure_class(IllustratedChapter.new)
          end
          
          it "raises an error if passed an object that is not an instance of the definition class" do
            lambda {
              subject.ensure_class(NonChapter.new)
            }.should raise_error(MongoModel::AssociationTypeMismatch)
          end
          
          it "accepts instances of the definition class that have been reloaded" do
            # Ensure Chapter class name is cached on the original class
            Chapter.name
            
            Object.send(:remove_const, :Chapter)
            Object.const_set(:Chapter, Class.new(MongoModel::Document))
            
            subject.ensure_class(Chapter.new)
          end
          
          it "accepts stale instances of a class that has been reloaded" do
            chapter = Chapter.new
            
            Object.send(:remove_const, :Chapter)
            Object.const_set(:Chapter, Class.new(MongoModel::Document))
            
            definition = double(:klass => Chapter)
            association = Association.new(definition, instance)
            
            association.ensure_class(chapter)
          end
        end
      end
    end
  end
end
