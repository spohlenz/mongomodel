require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/module/delegation'
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
        properties.reject { |k, p| p.internal? }
      end
    end
  
    class Property
      delegate :cast, :boolean, :to_mongo, :from_mongo, :to => :type_converter
      
      attr_reader :name, :type, :options
    
      def initialize(name, type, options={})
        @name, @type, @options = name, type, options
      end
    
      def as
        options[:as] || name.to_s
      end
    
      def default(instance)
        default = options[:default]
        
        if default.respond_to?(:call)
          case default.arity
          when 0 then default.call
          else        default.call(instance)
          end
        else
          default
        end
      end
    
      def ==(other)
        other.is_a?(self.class) && name == other.name && type == other.type && options == other.options
      end
      
      def embeddable?
        type.ancestors.include?(EmbeddedDocument)
      end
      
      def internal?
        as =~ /^_/ || options[:internal]
      end
      
    private
      def type_converter
        @type_converter ||= Types.converter_for(type)
      end
    end
  end
end
