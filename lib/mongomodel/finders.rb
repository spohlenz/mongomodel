require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/module/delegation'

module MongoModel
  module Finders
    def find(*args)
      options = args.extract_options!
      
      case args.first
      when :first then find_first(options)
      when :last then  find_last(options)
      when :all then   find_all(options)
      else             find_by_ids(args, options)
      end
    end
    
    def first(options={})
      find(:first, options)
    end
    
    def last(options={})
      find(:last, options)
    end
    
    def all(options={})
      find(:all, options)
    end
  
  private
    def finder
      @_finder ||= Finder.new(self)
    end
    
    def find_first(options={})
      finder.find(options.merge(:limit => 1)).first
    end
    
    def find_last(options={})
      finder.find(options.reverse_merge(:order => :id.desc).merge(:limit => 1)).first
    end
    
    def find_all(options={})
      finder.find(options)
    end
    
    def find_by_ids(ids, options={})
      ids.flatten!
      
      case ids.size
      when 0
        raise ArgumentError, "At least one id must be specified"
      when 1
        id = ids.first.to_s
        finder.find(options.deep_merge(:conditions => { :id => id })).first || raise(DocumentNotFound, "Couldn't find document with id: #{id}")
      else
        docs = finder.find(options.deep_merge(:conditions => { :id.in => ids.map { |id| id.to_s } }))
        raise DocumentNotFound if docs.size != ids.size
        docs
      end
    end
  end
  
  class FinderOperator
    attr_reader :field, :operator
    
    def initialize(field, operator)
      @field, @operator = field, operator
    end
    
    def to_mongo_conditions(value)
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
  
  class Finder
    delegate :collection, :properties, :to => :@model
    
    ValidFindOptions = [ :conditions, :select, :offset, :limit, :order ]
    
    def initialize(model)
      @model = model
    end
    
    def find(options={})
      options.assert_valid_keys(ValidFindOptions)
      
      selector, options = convert_options(options)
      instantiate(collection.find(selector, options).to_a)
    end
  
  private
    def convert_options(options)
      selector = convert_conditions(options[:conditions] || {})
      
      fields   = options[:select]
      skip     = options[:offset]
      limit    = options[:limit]
      sort     = convert_order(options[:order] || '')
      
      [selector, { :fields => fields, :skip => skip, :limit => limit, :sort => sort }]
    end
    
    def convert_conditions(conditions)
      conditions.inject({}) do |result, (k, v)|
        if k.is_a?(FinderOperator)
          field = k.field
          value = k.to_mongo_conditions(v)
        else
          field = k
          value = v
        end
        
        result[properties[field].as] = value
        
        result
      end
    end
    
    def convert_order(order)
      case order
      when Array
        order.map { |clause|
          property, sort = clause.split(/ /)
          
          property = @model.properties[property.to_sym].as
          sort = (sort =~ /desc/i) ? 'descending' : 'ascending'
          
          [property, sort]
        } if order.size > 0
      when String
        convert_order(order.split(/\b,\b/))
      end
    end
    
    def instantiate(documents)
      case documents
      when Array
        documents.map { |doc| instantiate(doc) }
      else
        @model.from_mongo(documents)
      end
    end
  end
end
