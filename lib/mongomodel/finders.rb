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
    
    def count(options={})
      collection.find(MongoOptions.new(self, options).selector).count
    end
  
  private
    def find_first(options={})
      _find(options.merge(:limit => 1)).first
    end
    
    def find_last(options={})
      _find(options.reverse_merge(:order => :id.desc).merge(:limit => 1)).first
    end
    
    def find_all(options={})
      _find(options)
    end
    
    def find_by_ids(ids, options={})
      ids.flatten!
      
      case ids.size
      when 0
        raise ArgumentError, "At least one id must be specified"
      when 1
        id = ids.first.to_s
        _find(options.deep_merge(:conditions => { :id => id })).first || raise(DocumentNotFound, "Couldn't find document with id: #{id}")
      else
        docs = _find(options.deep_merge(:conditions => { :id.in => ids.map { |id| id.to_s } }))
        raise DocumentNotFound if docs.size != ids.size
        docs
      end
    end
    
    def _find(options={})
      selector, options = MongoOptions.new(self, options).to_a
      docs = collection.find(selector, options).to_a
      docs.map { |doc| from_mongo(doc) }
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
