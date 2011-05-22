module MongoModel
  module Types
    class Array < Object
      def to_mongo(array)
        array.map { |i|
          Types.converter_for(i.class).to_mongo(i)
        } if array
      end
      
      def to_query(value)
        Types.converter_for(value.class).to_mongo(value)
      end
    end
  end
end
