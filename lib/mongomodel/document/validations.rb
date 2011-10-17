module MongoModel
  module DocumentExtensions
    module Validations
      extend ActiveSupport::Concern

      module ClassMethods
        def property(name, *args, &block) #:nodoc:
          property = super
          
          validates_uniqueness_of(name) if property.options[:unique]
          
          property
        end
        
        # Creates an object just like Document.create but calls save! instead of save
        # so an exception is raised if the document is invalid.
        def create!(attributes={}, &block)
          if attributes.is_a?(Array)
            attributes.map { |attrs| create!(attrs, &block) }
          else
            object = new(attributes, &block)
            object.save!
            object
          end
        end
      end
    
      # The validation process on save can be skipped by passing <tt>:validate => false</tt>. The regular Document#save method is
      # replaced with this when the validations module is mixed in, which it is by default.
      def save(options={})
        if perform_validation(options)
          begin
            super
          rescue DocumentNotSaved
            valid?
            false
          end
        else
          false
        end
      end
    
      # Attempts to save the document just like Document#save but will raise a DocumentInvalid exception
      # instead of returning false if the document is not valid.
      def save!(options={})
        if perform_validation(options)
          begin
            super
          rescue DocumentNotSaved => e
            valid? ? raise : raise(DocumentInvalid.new(self))
          end
        else
          raise DocumentInvalid.new(self)
        end
      end
    
    protected
      def perform_validation(options={})
        perform_validation = options != false && options[:validate] != false
        perform_validation ? valid?(options[:context]) : true
      end
    end
  end
end

Dir[File.dirname(__FILE__) + "/validations/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "mongomodel/document/validations/#{filename}"
end
