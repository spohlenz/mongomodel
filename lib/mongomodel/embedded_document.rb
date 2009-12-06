module MongoModel
  class EmbeddedDocument
    def initialize(attrs={})
      set_new_record(true)
      self.attributes = attrs
      yield self if block_given?
    end
    
    def ==(other)
      other.is_a?(self.class) && other.attributes == attributes
    end
    
    def new_record?
      @_new_record
    end
  
  private
    def set_new_record(value)
      @_new_record = value
      embedded_documents.each { |doc| doc.send(:set_new_record, value) }
      value
    end
  end
  
  EmbeddedDocument.class_eval do
    include Properties
    
    include Validations
    include Callbacks
    
    include Attributes
    include AttributeMethods
    include AttributeMethods::Read
    include AttributeMethods::Write
    include AttributeMethods::Query
    include AttributeMethods::BeforeTypeCast
    include AttributeMethods::Protected
    include AttributeMethods::Dirty
    
    include PrettyInspect
  end
end
