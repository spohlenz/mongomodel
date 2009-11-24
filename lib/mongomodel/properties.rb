require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/except'

module MongoModel
  module Properties
    extend ActiveSupport::Concern
    
    included do
      class_inheritable_accessor :properties
      self.properties = ActiveSupport::OrderedHash.new
    end
    
    module ClassMethods
      def property(name, type, options={})
        properties[name.to_sym] = Property.new(name, type, options)
      end
      
      def model_properties
        properties.except(:id)
      end
    end
  
    class Property
      attr_reader :name, :type, :options
    
      def initialize(name, type, options={})
        @name, @type, @options = name, type, options
      end
    
      def as
        options[:as] || name.to_s
      end
    
      def default(instance)
        default = options[:default]
        default.respond_to?(:call) ? default.call(instance) : default
      end
    
      def ==(other)
        other.is_a?(self.class) && name == other.name && type == other.type && options == other.options
      end
    
      def cast(value)
        type_converter.cast(value)
      end
    
      def to_mongo(value)
        type_converter.to_mongo(value)
      end
    
      def from_mongo(value)
        type_converter.from_mongo(value)
      end
    
    private
      def type_converter
        @type_converter ||= Types.converter_for(type)
      end
    end
  end
end
