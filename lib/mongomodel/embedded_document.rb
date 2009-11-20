module MongoModel
  class EmbeddedDocument
    include Properties
    include Attributes
    
    def initialize(attrs={})
      self.attributes = attrs
    end
    
    def ==(other)
      other.is_a?(self.class) && other.attributes == attributes
    end
  end
end
