require 'active_support/core_ext/class/attribute'

module MongoModel
  class Collection < Array
    module PropertyDefaults
      def property(name, *args, &block) #:nodoc:
        property = super(name, *args, &block)
        
        if property.type <= Collection
          property.options[:default] ||= lambda { property.type.new }
        end
        
        property
      end
    end
    
    ARRAY_CONVERTER = Types.converter_for(Array)
    
    class_attribute :type
    self.type = Object
    
    include DocumentParent
    
    def initialize(array=[])
      super(array.map { |i| convert_for_add(i) })
    end
    
    def []=(index, value)
      super(index, convert_for_add(value))
    end
    
    def <<(value)
      super(convert_for_add(value))
    end
    
    def build(value={})
      value = convert(value)
      self << value
      value
    end
    
    def +(other)
      self.class.new(super(other))
    end
    
    def concat(values)
      super(values.map { |v| convert_for_add(v) })
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
      super(index, convert_for_add(value))
    end
    
    def push(*values)
      super(*values.map { |v| convert_for_add(v) })
    end
    
    def rindex(value)
      super(convert(value))
    end
    
    def unshift(*values)
      super(*values.map { |v| convert_for_add(v) })
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
      
      # Create a new MongoModel::Collection class with the type set to the specified class.
      # This allows you declare arrays of embedded documents like:
      #
      #   class Thing < MongoModel::EmbeddedDocument
      #     property :name, String
      #   end
      #   
      #   class MyModel < MongoModel::Document
      #     property :things, Collection[Thing]
      #   end
      #
      # If you don't declare a default on a property that has a Collection type, the
      # default will be automatically set to an empty Collection.
      #
      # This method is aliased as #of, so you can use the alternative syntax:
      #    property :things, Collection.of(Thing)
      #
      # Examples:
      #
      #   model = MyModel.new
      #   model.things # => []
      #   model.things << {:name => "Thing One"}
      #   model.things # => [#<Thing name: "Thing One">]
      #   model.things = [{:name => "Thing Two"}] # => [#<Thing name: "Thing Two">]
      def [](type)
        @collection_class_cache ||= {}
        @collection_class_cache[type] ||= begin
          collection = Class.new(Collection)
          collection.type = type
          collection
        end
      end
      
      alias of []
      
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
    
    def convert_for_add(value)
      result = convert(value)
      result.parent_document = lambda { parent_document } if result.respond_to?(:parent_document=)
      result
    end
    
    def converter
      self.class.converter
    end
  end
end
