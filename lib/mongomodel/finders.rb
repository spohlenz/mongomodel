require 'active_support/core_ext/hash/keys'

module MongoModel
  module Finders
    def find(*args)
      options = args.extract_options!
      
      case args.first
      when :first then first(options)
      when :last then  last(options)
      when :all then   all(options)
      else             find_by_ids(args, options)
      end
    end
    
    def first(options={})
      finder.find(options.merge(:limit => 1)).first
    end
    
    def last(options={})
      finder.find(options.reverse_merge(:order => 'id DESC').merge(:limit => 1)).first
    end
    
    def all(options={})
      finder.find(options)
    end
  
  private
    def finder
      @_finder ||= Finder.new(self)
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
        docs = finder.find(options.deep_merge(:conditions => { :id => ids.map { |id| id.to_s } }))
        raise DocumentNotFound if docs.size != ids.size
        docs
      end
    end
  end
  
  class Finder
    ValidOptions = [ :conditions, :select, :offset, :limit, :order ]
    
    def initialize(klass)
      @klass = klass
    end
    
    def find(options={})
      options.assert_valid_keys(ValidOptions)
      
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
        result[@klass.properties[k].as] =
          case v
          when Array
            { '$in' => v }
          else
            v
          end
        
        result
      end
    end
    
    def convert_order(order)
      case order
      when Array
        order.map { |clause|
          property, sort = clause.split(/ /)
          
          property = @klass.properties[property.to_sym].as
          sort = (sort =~ /desc/i) ? 'descending' : 'ascending'
          
          [property, sort]
        } if order.size > 0
      when String
        convert_order(order.split(/\b,\b/))
      end
    end
  
    def collection
      @klass.collection
    end
    
    def instantiate(documents)
      case documents
      when Array
        documents.map { |doc| instantiate(doc) }
      else
        @klass.from_mongo(documents)
      end
    end
  end
end
