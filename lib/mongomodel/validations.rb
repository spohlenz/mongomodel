module MongoModel
  # Raised by <tt>save!</tt> and <tt>create!</tt> when the document is invalid.  Use the
  # +document+ method to retrieve the document which did not validate.
  #   begin
  #     complex_operation_that_calls_save!_internally
  #   rescue MongoModel::DocumentInvalid => invalid
  #     puts invalid.document.errors
  #   end
  class DocumentInvalid < DocumentNotSaved
    attr_reader :document
    
    def initialize(document)
      @document = document
      
      errors = @document.errors.full_messages.join(I18n.t('support.array.words_connector', :default => ', '))
      super(I18n.t('mongomodel.errors.messages.document_invalid', :errors => errors))
    end
  end
  
  module Validations
    extend ActiveSupport::Concern
    
    include ActiveModel::Validations
    
    module DocumentExtensions
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
          save_without_validation
        else
          false
        end
      end
    
      # Attempts to save the document just like Document#save but will raise a DocumentInvalid exception instead of returning false
      # if the document is not valid.
      def save_with_validation!
        if valid?
          save_without_validation!
        else
          raise DocumentInvalid.new(self)
        end
      end
    end
    
    module ClassMethods
      def property(name, *args, &block) #:nodoc:
        property = super(name, *args, &block)
        validates_embedded(name) if property.embeddable?
        property
      end
    end
    
    def valid?
      errors.clear
      
      @_on_validate = new_record? ? :create : :update
      run_callbacks(:validate)
      
      errors.empty?
    end
  end
end

Dir[File.dirname(__FILE__) + "/validations/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "mongomodel/validations/#{filename}"
end
