require 'active_support/core_ext/hash/indifferent_access'

module MongoModel
  module Types
    class Custom < Object
      def initialize(type)
        @type = type
      end
      
      def cast(value)
        if value.is_a?(@type)
          value
        elsif @type.respond_to?(:cast)
          @type.cast(value)
        else
          @type.new(value)
        end
      end
      
      def to_mongo(value)
        if value.respond_to?(:to_mongo)
          value.to_mongo
        else
          value
        end
      end
      
      def from_mongo(value)
        if @type.respond_to?(:from_mongo)
          value = value.with_indifferent_access if value.respond_to?(:with_indifferent_access)
          @type.from_mongo(value)
        else
          value
        end
      end
    end
  end
end
