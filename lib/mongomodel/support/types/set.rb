require 'set'

module MongoModel
  module Types
    class Set < Array
      def cast(obj)
        ::Set.new(::Array.wrap(obj))
      end
    end
  end
end

MongoModel::Types.register_converter(Set, MongoModel::Types::Set.new)
