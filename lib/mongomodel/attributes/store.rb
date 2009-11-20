module MongoModel
  module Attributes
    class Store < ActiveSupport::OrderedHash
      include Typecasting
      include Mongo
      
      attr_reader :properties
      
      def initialize(properties)
        super()
        @properties = properties
      end
      
      def inspect
        "{#{map { |k, v| "#{k.inspect}=>#{v.inspect}"}.join(', ')}}"
      end
      
      def set_defaults!(document)
        properties.each do |name, property|
          self[name] = property.default(document)
        end
      end
    end
  end
end
