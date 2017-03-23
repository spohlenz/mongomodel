module MongoModel
  module AttributeMethods
    module BeforeTypeCast
      extend ActiveSupport::Concern

      included do
        attribute_method_suffix "_before_type_cast"
      end

      # Returns an attribute value before typecasting.
      def read_attribute_before_type_cast(name)
        attributes.before_type_cast(name.to_sym)
      end

      # Returns a hash of attributes before typecasting.
      def attributes_before_type_cast
        attributes.keys.inject({}) do |result, key|
          result[key] = attributes.before_type_cast(key)
          result
        end
      end

    private
      def attribute_before_type_cast(attribute_name)
        read_attribute_before_type_cast(attribute_name)
      end
    end
  end
end
