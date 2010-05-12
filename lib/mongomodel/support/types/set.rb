module MongoModel
  module Types
    class Set < Array
      def cast(obj)
        ::Set.new(::Array.wrap(obj))
      end
    end
  end
end
