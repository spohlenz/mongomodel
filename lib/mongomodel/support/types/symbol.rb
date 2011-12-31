module MongoModel
  module Types
    class Symbol < Object
      def cast(value)
        value.to_sym if value && value.respond_to?(:to_sym)
      end
    end
  end
end

MongoModel::Types.register_converter(Symbol, MongoModel::Types::Symbol)
