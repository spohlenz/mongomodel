module MongoModel
  module Attributes
    module Typecasting
      def [](key)
        value = super(key)
        typecast_read(key, value)
      end
      
      def before_type_cast(key)
        fetch(key)
      end
    
    private
      def typecast_read(key, value)
        unless value.nil?
          property = properties[key]
          property ? property.cast(value) : value
        end
      end
    end
  end
end
