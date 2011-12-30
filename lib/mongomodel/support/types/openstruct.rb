module MongoModel
  module Types
    class OpenStruct
      def cast(value)
        ::OpenStruct.new(value)
      end

      def to_mongo(value)
        value.marshal_dump
      end

      def from_mongo(value)
        ::OpenStruct.new(value)
      end
    end
  end
end
