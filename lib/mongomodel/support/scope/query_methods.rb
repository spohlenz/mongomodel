module MongoModel
  class Scope
    module QueryMethods
      def initialize(*)
        SINGLE_VALUE_METHODS.each { |m| instance_variable_set("@#{m}_value", nil) }
        MULTI_VALUE_METHODS.each { |m| instance_variable_set("@#{m}_values", []) }
      end
      
      MULTI_VALUE_METHODS.each do |query_method|
        attr_accessor :"#{query_method}_values"
        
        class_eval <<-CEVAL, __FILE__
          def #{query_method}(*args, &block)
            new_scope = clone
            value = Array.wrap(args.flatten).reject {|x| x.blank? }
            new_scope.#{query_method}_values += value if value.present?
            new_scope
          end
        CEVAL
      end
      
      SINGLE_VALUE_METHODS.each do |query_method|
        attr_accessor :"#{query_method}_value"

        class_eval <<-CEVAL, __FILE__
          def #{query_method}(value, &block)
            new_scope = clone
            new_scope.#{query_method}_value = value
            new_scope
          end
        CEVAL
      end
      
      def from(value, &block)
        new_scope = clone
        new_scope.from_value = InstrumentedCollection.new(value.is_a?(String) ? klass.database.collection(value) : value)
        new_scope
      end
      
      def reverse_order
        if order_values.empty?
          order(:id.desc)
        else
          except(:order).order(MongoOrder.parse(order_values).reverse.to_a)
        end
      end
    end
  end
end
