module MongoModel
  module DocumentExtensions
    module DynamicFinders
      def respond_to?(method_id, include_private = false)
        if DynamicFinder.match(scoped, method_id)
          true
        else
          super
        end
      end

      def method_missing(method_id, *args, &block)
        if finder = DynamicFinder.match(scoped, method_id)
          finder.execute(*args)
        else
          super
        end
      end
    end
  end
end
