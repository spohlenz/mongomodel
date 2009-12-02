require 'active_support/core_ext/hash/indifferent_access'

module MongoModel
  module Types
    class Hash < Object
      def to_mongo(hash)
        hash.inject({}) { |result, (k, v)|
          result[k] = Types.converter_for(v.class).to_mongo(v)
          result
        }
      end
      
      def from_mongo(hash)
        hash.with_indifferent_access if hash
      end
    end
  end
end
