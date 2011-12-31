module MongoModel
  module Types
    class String < Object
      def cast(value)
        value.to_s if value && value.respond_to?(:to_s)
      end
    end
  end
end

MongoModel::Types.register_converter(String, MongoModel::Types::String)
