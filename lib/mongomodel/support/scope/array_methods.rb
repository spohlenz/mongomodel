module MongoModel
  class Scope
    module ArrayMethods
      def any?(&block)
        if block_given?
          to_a.any?(&block)
        else
          !empty?
        end
      end

      def select(*args, &block)
        if block_given?
          to_a.select(&block)
        else
          super
        end
      end
    end
  end
end
