module MongoModel
  class Map < Hash
    module PropertyDefaults
      def property(name, *args, &block) #:nodoc:
        property = super(name, *args, &block)
        
        if property.type <= Map
          property.options[:default] ||= lambda { property.type.new }
        end
        
        property
      end
    end
    
    class_inheritable_accessor :from
    self.from = String
    
    class_inheritable_accessor :to
    self.to = Object
    
    HASH_CONVERTER = Types.converter_for(Hash)
    
    class << self
      def [](mapping)
        raise "Exactly one mapping must be specified" unless mapping.keys.size == 1
        
        from = mapping.keys.first
        to   = mapping.values.first
        
        @map_class_cache ||= {}
        @map_class_cache[[from, to]] ||= begin
          map = Class.new(Map)
          map.from = from
          map.to   = to
          map
        end
      end
      
      def from_mongo(hash)
        result = new
        hash.each_pair { |k, v| result[from_converter.from_mongo(k)] = instantiate(v) }
        result
      end
      
      def inspect
        if self == Map
          "Map"
        else
          "Map[#{from} => #{to}]"
        end
      end
      
      def from_converter
        @from_converter ||= Types.converter_for(from)
      end
      
      def to_converter
        @to_converter ||= Types.converter_for(to)
      end
      
    private
      def instantiate(item)
        if item.is_a?(Hash) && item['_type']
          item['_type'].constantize.from_mongo(item)
        else
          to_converter.from_mongo(item)
        end
      end
    end
    
    def initialize(hash={})
      super()
      update(hash)
    end
    
    def to_mongo
      HASH_CONVERTER.to_mongo(self)
    end
    
    def [](key)
      super(convert_key(key))
    end
    
    def []=(key, value)
      super(convert_key(key), convert_value(value))
    end
    
    def store(key, value)
      super(convert_key(key), convert_value(value))
    end
    
    def delete(key)
      super(convert_key(key))
    end
    
    def fetch(key, *args, &block)
      super(convert_key(key), *args, &block)
    end
    
    def key?(key)
      super(convert_key(key))
    end
    
    alias_method :include?, :key?
    alias_method :has_key?, :key?
    alias_method :member?, :key?
    
    def value?(value)
      super(convert_value(value))
    end
    
    alias_method :has_value?, :value?
    
    def index(value)
      super(convert_value(value))
    end
    
    def update(hash)
      hash.each_pair { |k, v| self[k] = v }
      self
    end
    
    def replace(hash)
      clear
      update(hash)
    end
    
    def merge(hash)
      dup.update(super(hash))
    end
    
    def merge!(hash)
      update(merge(hash))
    end
    
    def values_at(*keys)
      super(*keys.map { |k| convert_key(k) })
    end
  
  private
    def convert_key(key)
      self.class.from_converter.cast(key)
    end
    
    def convert_value(value)
      self.class.to_converter.cast(value)
    end
  end
end
