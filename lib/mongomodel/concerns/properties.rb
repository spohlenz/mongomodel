require 'active_support/core_ext/object/duplicable'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/except'

module MongoModel
  module Properties
    extend ActiveSupport::Concern

    def properties
      self.class.properties
    end

    module ClassMethods
      def property(name, type, options={})
        properties[name.to_sym] = Property.new(name, type, options).tap do |property|
          include type.mongomodel_accessors(property) if type.respond_to?(:mongomodel_accessors)
        end
      end

      def properties
        @properties ||= ActiveSupport::OrderedHash.new
      end

      def properties=(properties)
        @properties = properties
      end

      def model_properties
        properties.reject { |k, p| p.internal? }
      end

      def internal_properties
        properties.select { |k, p| p.internal? }.map { |k, p| p }
      end

      def inherited(subclass)
        super
        subclass.properties = properties.dup
      end
    end

    class Property
      delegate :cast, :boolean, :to_mongo, :from_mongo, :to_query, :to => :type_converter

      attr_reader :name, :type, :options

      def initialize(name, type, options={})
        @name, @type, @options = name.to_sym, type, options
      end

      def as
        options[:as] || name.to_s
      end

      def default(instance)
        if options.key?(:default)
          default = options[:default]

          if default.is_a?(Proc)
            case default.arity
            when 0 then instance.instance_exec(&default)
            else        instance.instance_exec(instance, &default)
            end
          else
            default.duplicable? ? default.dup : default
          end
        elsif type.respond_to?(:mongomodel_default)
          type.mongomodel_default(instance)
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

      def validate?
        options[:validate] != false
      end

    private
      def type_converter
        @type_converter ||= Types.converter_for(type)
      end
    end
  end
end
