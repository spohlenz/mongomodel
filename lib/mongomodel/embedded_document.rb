module MongoModel
  class EmbeddedDocument
    include Properties
    
    include Attributes
    include AttributeMethods
    include AttributeMethods::Read
    include AttributeMethods::Write
    include AttributeMethods::Query
    include AttributeMethods::BeforeTypeCast
    
    include PrettyInspect
    
    def initialize(attrs={})
      self.attributes = attrs
      yield self if block_given?
    end
    
    def ==(other)
      other.is_a?(self.class) && other.attributes == attributes
    end
  end
end
