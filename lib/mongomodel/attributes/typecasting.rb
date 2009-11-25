module MongoModel
  module Attributes
    module Typecasting
      def [](key)
        value = super(key)
        typecast_read(key, value)
      end
      
      # Check if key has a value that typecasts to true.
      #
      # attributes = Attributes::Store.new(:comments_count => Property.new(:comments_count, Integer))
      #
      # attributes[:comments_count] = 0
      # attributes.has?(:comments_count)
      # => false
      #
      # attributes[:comments_count] = 1
      # attributes.has?(:comments_count)
      # => true
      #
      def has?(key)
        value = self[key]
        boolean_typecast(key, value)
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
      
      def boolean_typecast(key, value)
        if property = properties[key]
          value ? property.boolean(value) : false
        else
          !!value
        end
      end
    end
  end
end
