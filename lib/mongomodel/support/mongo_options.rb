require 'active_support/core_ext/class/subclasses'

module MongoModel
  class MongoOptions
    ValidKeys = [ :conditions, :select, :offset, :limit, :order ]
    
    attr_reader :selector, :options
    
    def initialize(model, options={})
      options.assert_valid_keys(ValidKeys)
      
      @model = model
      
      @selector = extract_conditions(options)
      @options  = extract_options(options)
      
      add_type_to_selector
    end
    
    def to_a
      [selector, options]
    end
  
  private
    def extract_conditions(options)
      result = {}
      
      (options[:conditions] || {}).each do |k, v|
        if k.is_a?(MongoOperator)
          key = k.field
          value = k.to_mongo_selector(v)
        else
          key = k
          value = v
        end
        
        property = @model.properties[key]
        
        result[property ? property.as : key] = value
      end
      
      result
    end
    
    def extract_options(options)
      result = {}
      
      result[:fields] = options[:select] if options[:select]
      result[:skip]   = options[:offset] if options[:offset]
      result[:limit]  = options[:limit]  if options[:limit]
      result[:sort]   = MongoOrder.parse(options[:order]).to_sort(@model) if options[:order]
      
      result
    end
    
    def convert_order(order)
      case order
      when Array
        order.map { |clause|
          key, sort = clause.split(/ /)
          
          property = @model.properties[key.to_sym]
          sort = (sort =~ /desc/i) ? :descending : :ascending
          
          [property ? property.as : key, sort]
        } if order.size > 0
      when String, Symbol
        convert_order(order.to_s.split(/,/).map { |c| c.strip })
      end
    end
    
    def add_type_to_selector
      unless selector['_type'] || @model.superclass.abstract_class?
        selector['_type'] = { '$in' => [@model.to_s] + @model.subclasses }
      end
    end
  end
  
  class MongoOrder
    attr_reader :clauses
    
    def initialize(*clauses)
      @clauses = clauses
    end
    
    def to_s
      clauses.map { |c| c.to_s }.join(', ')
    end
    
    def to_sort(model)
      clauses.map { |c| c.to_sort(model.properties[c.field]) }
    end
    
    def ==(other)
      other.is_a?(self.class) && clauses == other.clauses
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
      
      def self.parse(clause)
        case clause
        when Clause
          clause
        when String, Symbol
          field, order = clause.to_s.strip.split(/ /)
          new(field, order =~ /^desc/i ? :descending : :ascending)
        end
      end
    end
  end
  
  class MongoOperator
    attr_reader :field, :operator
    
    def initialize(field, operator)
      @field, @operator = field, operator
    end
    
    def to_mongo_selector(value)
      { "$#{operator}" => value }
    end
    
    def inspect
      "#{field.inspect}.#{operator}"
    end
    
    def ==(other)
      other.is_a?(self.class) && field == other.field && operator == other.operator
    end
    
    def hash
      field.hash ^ operator.hash
    end
    
    def eql?(other)
      self == other
    end
  end
end
