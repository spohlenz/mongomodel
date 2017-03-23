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
        k = k.to_mongo_operator if k.respond_to?(:to_mongo_operator)

        key = k.respond_to?(:field) ? k.field : k

        if @model.respond_to?(:properties) && property = @model.properties[key]
          key = property.as
          value = v.is_a?(Array) ? v.map { |i| property.to_query(i) } : property.to_query(v);
        else
          value = Types.converter_for(v.class).to_mongo(v)
        end

        if k.respond_to?(:to_mongo_selector)
          selector = k.to_mongo_selector(value)

          if result[key].is_a?(Hash)
            result[key].merge!(selector)
          else
            result[key] ||= selector
          end
        else
          result[key] = value
        end
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
      if use_type_selector?
        selector['_type'] = { '$in' => @model.type_selector }
      end
    end

    def use_type_selector?
      @model.respond_to?(:use_type_selector?) && @model.use_type_selector? && selector['_type'].nil?
    end
  end
end
