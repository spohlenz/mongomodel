module MongoModel
  class Scope
    module SpawnMethods
      def merge(scope)
        result = clone

        MULTI_VALUE_METHODS.each do |method|
          values = send(:"#{method}_values") + scope.send(:"#{method}_values")
          result.send(:"#{method}_values=", values.uniq)
        end

        SINGLE_VALUE_METHODS.each do |method|
          value = scope.send(:"#{method}_value")
          result.send(:"#{method}_value=", value) if value
        end

        result.on_load_proc = scope.on_load_proc

        result
      end

      def except(*exceptions)
        result = self.class.new(klass)

        MULTI_VALUE_METHODS.each do |method|
          result.send(:"#{method}_values=", send(:"#{method}_values")) unless exceptions.include?(method)
        end

        SINGLE_VALUE_METHODS.each do |method|
          result.send(:"#{method}_value=", send(:"#{method}_value")) unless exceptions.include?(method)
        end

        result
      end
    end
  end
end
