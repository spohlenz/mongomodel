module MongoModel
  module Types
    class Integer < Object
      def cast(value)
        to_integer(value) if value
      end

      def boolean(value)
        !value.zero?
      end

      def from_mongo(value)
        to_integer(value)
      end

    private
      def to_integer(value)
        Kernel::Integer(value)
      rescue ArgumentError, TypeError
        Kernel::Float(value).to_i rescue nil
      end
    end
  end
end

MongoModel::Types.register_converter(Integer, MongoModel::Types::Integer.new)
