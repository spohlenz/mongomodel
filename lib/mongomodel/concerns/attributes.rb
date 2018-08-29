require 'active_support/core_ext/module/aliasing'

module MongoModel
  module Attributes
    extend ActiveSupport::Concern

    def initialize(attrs={}, options={})
      assign_attributes(attrs || {}, options)
      yield self if block_given?
    end

    def attributes
      @attributes ||= Attributes::Store.new(self)
    end

    def assign_attributes(attrs, options={})
      return unless attrs

      attrs.each do |attr, value|
        if respond_to?("#{attr}=")
          send("#{attr}=", value)
        else
          write_attribute(attr, value)
        end
      end
    end

    def attributes=(attrs)
      assign_attributes(attrs)
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

      attributes.values.select { |attr| attr.is_a?(Map) && attr.to <= EmbeddedDocument }.each do |map|
        docs.concat map.values
      end

      docs
    end

  protected
    def sanitize_for_mass_assignment(attrs, options={})
      attrs
    end

    module ClassMethods
      def from_mongo(hash)
        if hash
          doc = class_for_type(hash['_type']).new
          doc.attributes.load!(hash)
          doc
        end
      end

    private
      def class_for_type(type)
        klass = type.constantize

        if klass.ancestors.map(&:name).include?(name)
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
