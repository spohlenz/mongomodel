module MongoModel
  module Types
    class Integer < Object
      def cast(value)
        value.to_i if value.respond_to?(:to_i)
      end
    end
  end
end
