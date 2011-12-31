module MongoModel
  module Types
    class Array < Object
      def to_mongo(array)
        array.map { |i| convert(i) } if array
      end
      
      def to_query(value)
        convert(value)
      end
    end
  end
end

MongoModel::Types.register_converter(Array, MongoModel::Types::Array.new)
