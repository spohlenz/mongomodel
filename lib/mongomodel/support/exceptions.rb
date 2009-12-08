module MongoModel
  class DocumentNotFound < StandardError; end
  
  class DocumentNotSaved < StandardError; end
  
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
end
