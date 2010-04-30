module MongoModel
  module DocumentParent
    extend ActiveSupport::Concern
    
    def parent_document
      @_parent_document.is_a?(Proc) ? @_parent_document.call(self) : @_parent_document
    end
    
    def parent_document=(doc)
      @_parent_document = doc
    end
  end
end
