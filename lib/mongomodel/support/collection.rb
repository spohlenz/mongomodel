module MongoModel
  class Collection < Array
    ARRAY_CONVERTER = Types.converter_for(Array)
    
    class_inheritable_accessor :type
    self.type = Object
    
    def initialize(array=[])
      super(array.map { |i| convert(i) })
    end
    
    def []=(index, value)
      super(index, convert(value))
    end
    
    def <<(value)
      super(convert(value))
    end
    
    def +(other)
      self.class.new(super(other))
    end
    
    def concat(values)
      super(values.map { |v| convert(v) })
    end
    
    def delete(value)
      super(convert(value))
    end
    
    def include?(value)
      super(convert(value))
    end
    
    def index(value)
      super(convert(value))
    end
    
    def insert(index, value)
      super(index, convert(value))
    end
    
    def push(*values)
      super(*values.map { |v| convert(v) })
    end
    
    def rindex(value)
      super(convert(value))
    end
    
    def unshift(*values)
      super(*values.map { |v| convert(v) })
    end
    
    def to_mongo
      ARRAY_CONVERTER.to_mongo(self)
    end
    
    def embedded_documents
      select { |item| item.is_a?(EmbeddedDocument) }
    end
    
    class << self
      def inspect
        if type == Object
          "Collection"
        else
          "Collection[#{type}]"
        end
      end
    
      def [](type)
        @collection_class_cache ||= {}
        @collection_class_cache[type] ||= begin
          collection = Class.new(Collection)
          collection.type = type
          collection
        end
      end
      
      def from_mongo(array)
        new(array.map { |i| instantiate(i) })
      end
    
      def converter
        @converter ||= Types.converter_for(type)
      end
    
    private
      def instantiate(item)
        if item.is_a?(Hash) && item['_type']
          item['_type'].constantize.from_mongo(item)
        else
          converter.from_mongo(item)
        end
      end
    end
  
  private
    def convert(value)
      converter.cast(value)
    end
    
    def converter
      self.class.converter
    end
  end
end
