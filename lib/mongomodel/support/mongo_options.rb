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
        key = k.is_a?(MongoOperator) ? k.field : k
        
        if property = @model.properties[key]
          key = property.as
          value = v.is_a?(Array) ? v.map { |i| property.to_query(i) } : property.to_query(v);
        else
          value = Types.converter_for(v.class).to_mongo(v)
        end

        result[key] = k.is_a?(MongoOperator) ? k.to_mongo_selector(value) : value
      end
      
      result
    end
    
    def extract_options(options)
      result = {}
      
      result[:fields] = convert_select(options[:select]) if options[:select]
      result[:skip]   = options[:offset] if options[:offset]
      result[:limit]  = options[:limit]  if options[:limit]
      result[:sort]   = MongoOrder.parse(options[:order]).to_sort(@model) if options[:order]
      
      result
    end
    
    def convert_select(fields)
      fields.map do |key|
        (@model.properties[key.to_sym].try(:as) || key).to_sym
      end
    end
    
    def add_type_to_selector
      if @model.use_type_selector? && selector['_type'].nil?
        selector['_type'] = { '$in' => @model.type_selector }
      end
    end
  end
end
