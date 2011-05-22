module MongoModel
  module Types
    class Object
      def cast(value)
        value
      end
      
      def boolean(value)
        !value.blank?
      end
      
      def to_mongo(value)
        value
      end
      
      def from_mongo(value)
        value
      end
      
      def to_query(value)
        to_mongo(cast(value))
      end
    end
  end
end
