require 'active_support/core_ext/module/aliasing'

module MongoModel
  module Attributes
    extend ActiveSupport::Concern
    
    included do
      alias_method_chain :initialize, :attributes
    end
    
    def initialize_with_attributes(attrs={})
      initialize_without_attributes
      
      self.attributes = attrs
      yield self if block_given?
    end
    
    def attributes
      @attributes ||= Attributes::Store.new(self)
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
    
    def freeze
      attributes.freeze; self
    end
    
    def frozen?
      attributes.frozen?
    end
    
    # Returns duplicated record with unfreezed attributes.
    def dup
      obj = super
      obj.instance_variable_set('@attributes', instance_variable_get('@attributes').dup)
      obj
    end
    
    def to_mongo
      attributes.to_mongo
    end
    
    def embedded_documents
      docs = []
      
      docs.concat attributes.values.select { |attr| attr.is_a?(EmbeddedDocument) }
      
      attributes.values.select { |attr| attr.is_a?(Collection) }.each do |collection|
        docs.concat collection.embedded_documents
      end
      
      docs
    end
    
    module ClassMethods
      def from_mongo(hash)
        doc = class_for_type(hash['_type']).new
        doc.attributes.from_mongo!(hash)
        doc
      end
    
    private
      def class_for_type(type)
        klass = type.constantize
        
        if (subclasses + [name]).include?(type)
          klass
        else
          raise DocumentNotFound, "Document not of the correct type (got #{type})"
        end
      rescue NameError
        self
      end
    end
  end
end
