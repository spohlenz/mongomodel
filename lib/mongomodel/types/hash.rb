require 'active_support/hash_with_indifferent_access'

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
        ActiveSupport::HashWithIndifferentAccess.new(hash)
      end
    end
  end
end
