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

    protected
      def convert(value)
        Types.converter_for(value.class).to_mongo(value)
      end
    end
  end
end
