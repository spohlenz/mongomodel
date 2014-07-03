require 'active_support/core_ext/module/delegation'

module MongoModel
  class Scope
    MULTI_VALUE_METHODS = [ :select, :order, :where ]
    SINGLE_VALUE_METHODS = [ :limit, :offset, :from ]
    
    autoload :ArrayMethods,   'mongomodel/support/scope/array_methods'
    autoload :SpawnMethods,   'mongomodel/support/scope/spawn_methods'
    autoload :QueryMethods,   'mongomodel/support/scope/query_methods'
    autoload :FinderMethods,  'mongomodel/support/scope/finder_methods'
    autoload :LoadMethods,    'mongomodel/support/scope/load_methods'
    autoload :DynamicFinders, 'mongomodel/support/scope/dynamic_finders'
    autoload :Pagination,     'mongomodel/support/scope/pagination'
    autoload :Batches,        'mongomodel/support/scope/batches'
    
    include Batches, Pagination, DynamicFinders, LoadMethods, FinderMethods, ArrayMethods, QueryMethods, SpawnMethods
    
    delegate :inspect, :as_json, :to => :to_a
    
    attr_reader :klass
    
    def initialize(klass)
      super
      
      @klass = klass
      
      @loaded = false
      @documents = []
    end
    
    def initialize_copy(other)
      reset
    end
    
    def build(*args, &block)
      new(*args, &block)
    end
    
    def to_a
      return @documents if loaded?
      
      @documents = _find_and_instantiate
      @loaded = true
      
      @documents
    end
    
    def size
      loaded? ? @documents.size : count
    end
    
    def empty?
      loaded? ? @documents.empty? : count.zero?
    end
    
    def count
      _find.count
    end
    
    def destroy_all
      to_a.each { |doc| doc.destroy }
      reset
    end
    
    def destroy(*ids)
      where(ids_to_conditions(ids)).destroy_all
      reset
    end
    
    def delete_all
      selector = MongoOptions.new(klass, :conditions => finder_conditions).selector
      collection.remove(selector, {})
      reset
    end
    
    def delete(*ids)
      where(ids_to_conditions(ids)).delete_all
      reset
    end
    
    def update_all(updates)
      if updates.any?
        selector = MongoOptions.new(klass, :conditions => finder_conditions).selector
        collection.update(selector, { "$set" => updates }, { :multi => true })
        reset
      else
        self
      end
    end
    
    def update(ids, updates)
      where(ids_to_conditions(ids)).update_all(updates)
      reset
    end
    
    def loaded?
      @loaded
    end
    
    def reload
      reset
      to_a
      self
    end
    
    def reset
      @loaded = nil
      @documents = []
      @finder_options = nil
      @options_for_create = nil
      self
    end
    
    def ==(other)
      case other
      when Scope
        klass == other.klass &&
          collection == other.collection &&
          finder_options == other.finder_options
      when Array
        to_a == other.to_a
      end
    end
    
    def collection
      from_value || klass.collection
    end
    
    def finder_options
      @finder_options ||= {}.tap do |result|
        result[:conditions] = finder_conditions if where_values.any?
        result[:select]     = select_values     if select_values.any?
        result[:order]      = order_values      if order_values.any?
        result[:limit]      = limit_value       if limit_value.present?
        result[:offset]     = offset_value      if offset_value.present?
      end
    end
    
    def options_for_create
      @options_for_create ||= finder_conditions.reject { |k, v| k.is_a?(MongoModel::MongoOperator) || k.respond_to?(:to_mongo_operator) }
    end
    
    def respond_to?(method, include_private = false)
      Array.method_defined?(method) || klass.respond_to?(method, include_private) || super
    end
  
  protected
    def method_missing(method, *args, &block)
      if Array.method_defined?(method)
        to_a.send(method, *args, &block)
      elsif klass.scopes[method]
        merge(klass.send(method, *args, &block))
      elsif klass.respond_to?(method)
        with_scope { klass.send(method, *args, &block) }
      else
        super
      end
    end
  
  private
    def _find
      ensure_indexes!
      selector, options = MongoOptions.new(klass, finder_options).to_a
      collection.find(selector, options)
    end
    
    def _find_and_instantiate
      _find.to_a.map { |doc|
        klass.from_mongo(doc).tap { |instance|
          on_load_proc.call(instance) if on_load_proc
        }
      }
    end
    
    def finder_conditions
      where_values.inject({}) { |conditions, v| conditions.merge(v) }
    end
    
    def with_scope(&block)
      klass.send(:with_scope, self, &block)
    end
    
    def ids_to_conditions(ids)
      ids = Array.wrap(ids).flatten
      
      if ids.size == 1
        { :id => ids.first.to_s }
      else
        { :id.in => ids.map { |id| id.to_s } }
      end
    end
    
    def ensure_indexes!
      if klass.respond_to?(:indexes_initialized?) && !klass.indexes_initialized?
        klass.ensure_indexes!
      end
    end
  end
end
