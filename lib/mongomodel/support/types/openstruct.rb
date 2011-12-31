module MongoModel
  module Types
    class OpenStruct < Object
      def cast(value)
        case value
        when ::OpenStruct
          value
        else
          ::OpenStruct.new(value)
        end
      end

      def to_mongo(value)
        value.marshal_dump if value
      end

      def from_mongo(value)
        ::OpenStruct.new(value)
      end
    end
  end
end

MongoModel::Types.register_converter(OpenStruct, MongoModel::Types::OpenStruct)
