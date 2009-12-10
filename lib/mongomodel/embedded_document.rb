module MongoModel
  class EmbeddedDocument
    def ==(other)
      other.is_a?(self.class) && other.attributes == attributes
    end
    
    include Attributes
    include Properties
    
    include Validations
    include Callbacks
    
    include AttributeMethods
    include AttributeMethods::Read
    include AttributeMethods::Write
    include AttributeMethods::Query
    include AttributeMethods::BeforeTypeCast
    include AttributeMethods::Protected
    include AttributeMethods::Dirty
    
    include RecordStatus
    include ActiveModelCompatibility
    include Timestamps
    include PrettyInspect
  end
end
