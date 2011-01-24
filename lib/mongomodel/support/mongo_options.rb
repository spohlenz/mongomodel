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
        else
          key = k
        end
        
        if property = @model.properties[key]
          key = property.as
          
          if k.is_a?(MongoOperator)
            value = k.to_mongo_selector(v.is_a?(Array) ? v.map { |i| property.to_mongo(property.cast(i)) } : property.to_mongo(property.cast(v)))
          else
            value = property.to_mongo(property.cast(v))
          end
        else
          converter = Types.converter_for(value.class)
          
          if k.is_a?(MongoOperator)
            value = k.to_mongo_selector(converter.to_mongo(v))
          else
            value = converter.to_mongo(v)
          end
        end
        
        result[key] = value
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
      if @model.use_type_selector? && selector['_type'].nil?
        selector['_type'] = { '$in' => @model.type_selector }
      end
    end
  end
end
