module MongoModel
  module Types
    class Hash < Object
      def to_mongo(hash)
        hash.inject({}) { |result, (k, v)|
          result[k] = Types.converter_for(v.class).to_mongo(v)
          result
        }
      end
    end
  end
end
