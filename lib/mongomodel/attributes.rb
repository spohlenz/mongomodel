module MongoModel
  module Attributes
    extend ActiveSupport::Concern
    
    def attributes
      @attributes ||= initialize_attribute_store
    end
    
    def attributes=(attrs)
      attrs.each do |attr, value|
        if respond_to?("#{attr}=")
          send("#{attr}=", value)
        else
          write_attribute(attr, value)
        end
      end
    end
    
    def to_mongo
      attributes.to_mongo
    end
    
    def embedded_documents
      attributes.values.select { |attr| attr.is_a?(EmbeddedDocument) }
    end
    
    module ClassMethods
      def from_mongo(hash)
        doc = new
        doc.attributes.from_mongo!(hash)
        doc
      end
    end
    
  private
    def initialize_attribute_store
      attributes = Attributes::Store.new(properties)
      attributes.set_defaults!(self)
      attributes
    end
  end
end
