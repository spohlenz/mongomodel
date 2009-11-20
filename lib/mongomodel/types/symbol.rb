module MongoModel
  module Types
    class Symbol < Object
      def cast(value)
        value.to_sym
      end
    end
  end
end
