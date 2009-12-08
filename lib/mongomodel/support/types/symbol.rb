module MongoModel
  module Types
    class Symbol < Object
      def cast(value)
        value.to_sym if value.respond_to?(:to_sym)
      end
    end
  end
end
