module MongoModel
  class MongoOptions
    ValidKeys = [ :conditions, :select, :offset, :limit, :order ]
    
    attr_reader :selector, :options
    
    def initialize(model, options={})
      options.assert_valid_keys(ValidKeys)
      
      @model = model
      
      @selector = extract_conditions(options)
      @options  = extract_options(options)
    end
    
    def to_a
      [selector, options]
    end
  
  private
    def extract_conditions(options)
      (options[:conditions] || {}).inject({}) do |result, (k, v)|
        if k.is_a?(MongoOperator)
          key = k.field
          value = k.to_mongo_selector(v)
        else
          key = k
          value = v
        end
        
        property = @model.properties[key]
        
        result[property ? property.as : key] = value
        
        result
      end
    end
    
    def extract_options(options)
      result = {}
      
      result[:fields] = options[:select] if options[:select]
      result[:skip]   = options[:offset] if options[:offset]
      result[:limit]  = options[:limit]  if options[:limit]
      result[:sort]   = convert_order(options[:order]) if options[:order]
      
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
      when String
        convert_order(order.split(/,/).map { |c| c.strip })
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
