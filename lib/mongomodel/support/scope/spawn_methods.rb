module MongoModel
  class Scope
    module SpawnMethods
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
