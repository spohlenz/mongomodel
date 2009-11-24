module MongoModel
  class EmbeddedDocument
    include Properties
    
    include Attributes
    include AttributeMethods
    include AttributeMethods::Read
    include AttributeMethods::Write
    
    include PrettyInspect
    
    def initialize(attrs={})
      self.attributes = attrs
    end
    
    def ==(other)
      other.is_a?(self.class) && other.attributes == attributes
    end
  end
end
