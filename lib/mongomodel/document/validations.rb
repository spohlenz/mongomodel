module MongoModel
  module DocumentExtensions
    module Validations
      extend ActiveSupport::Concern
      
      included do
        alias_method_chain :save, :validation
        alias_method_chain :save!, :validation
      end
    
      module ClassMethods
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
    
      # The validation process on save can be skipped by passing false. The regular Document#save method is
      # replaced with this when the validations module is mixed in, which it is by default.
      def save_with_validation(perform_validation = true)
        if perform_validation && valid? || !perform_validation
          begin
            save_without_validation
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
      def save_with_validation!
        if valid?
          begin
            save_without_validation!
          rescue DocumentNotSaved => e
            raise valid? ? e : DocumentInvalid.new(self)
          end
        else
          raise DocumentInvalid.new(self)
        end
      end
    end
  end
end

Dir[File.dirname(__FILE__) + "/validations/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "mongomodel/document/validations/#{filename}"
end
