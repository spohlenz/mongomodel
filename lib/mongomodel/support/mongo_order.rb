module MongoModel
  class MongoOrder
    attr_reader :clauses
    
    def initialize(*clauses)
      @clauses = clauses
    end
    
    def to_a
      clauses
    end
    
    def to_s
      clauses.map { |c| c.to_s }.join(', ')
    end
    
    def to_sort(model)
      clauses.map { |c| c.to_sort(model.respond_to?(:properties) ? model.properties[c.field] : nil) }
    end
    
    def ==(other)
      other.is_a?(self.class) && clauses == other.clauses
    end
    alias eql? ==
    
    def hash
      clauses.hash
    end
    
    def reverse
      self.class.new(*clauses.map { |c| c.reverse })
    end
    
    def self.parse(order)
      case order
      when MongoOrder
        order
      when Clause
        new(order)
      when Symbol
        new(Clause.new(order))
      when String
        new(*order.split(',').map { |c| Clause.parse(c) })
      when Array
        new(*order.map { |c| Clause.parse(c) })
      else
        new(order.to_mongo_order_clause) if order.respond_to?(:to_mongo_order_clause)
      end
    end
    
    class Clause
      attr_reader :field, :order
      
      def initialize(field, order=:ascending)
        @field, @order = field.to_sym, order.to_sym
      end
      
      def to_s
        "#{field} #{order}"
      end
      
      def to_sort(property)
        [property ? property.as : field.to_s, order]
      end
      
      def reverse
        self.class.new(field, order == :ascending ? :descending : :ascending)
      end
      
      def ==(other)
        other.is_a?(self.class) && field == other.field && order == other.order
      end
      alias eql? ==
      
      def hash
        [field, order].hash
      end
      
      def self.parse(clause)
        case clause
        when Clause
          clause
        when String, Symbol
          field, order = clause.to_s.strip.split(/ /)
          new(field, order =~ /^desc/i ? :descending : :ascending)
        else
          clause.to_mongo_order_clause if clause.respond_to?(:to_mongo_order_clause)
        end
      end
    end
  end
end
