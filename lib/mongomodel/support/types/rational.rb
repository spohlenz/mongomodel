module MongoModel
  module Types
    class Rational < Object
      def cast(value)
        Rational(value)
      end
      
      def to_mongo(value)
        value.to_s
      end
    end
  end
end
