require 'active_support/core_ext/module/delegation'

module MongoModel
  module Attributes
    class Store < ActiveSupport::OrderedHash
      include Typecasting
      include Mongo
      include Dirty
      
      attr_reader :instance
      delegate :properties, :to => :instance
      
      def initialize(instance)
        super()
        @instance = instance
        set_defaults!
      end
      
      def inspect
        "{#{map { |k, v| "#{k.inspect}=>#{v.inspect}"}.join(', ')}}"
      end
    
    private
      def set_defaults!
        properties.each do |name, property|
          self[name] = property.default(instance)
        end
      end
    end
  end
end
