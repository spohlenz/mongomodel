module MongoModel
  module Types
    class Float < Object
      def cast(value)
        value.to_f
      end
    end
  end
end
