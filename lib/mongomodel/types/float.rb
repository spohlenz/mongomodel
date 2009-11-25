module MongoModel
  module Types
    class Float < Object
      def cast(value)
        value.to_f if value.respond_to?(:to_f)
      end
      
      def boolean(value)
        !value.zero?
      end
    end
  end
end
