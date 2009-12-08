module MongoModel
  module AttributeMethods
    extend ActiveSupport::Concern
    
    include ActiveModel::AttributeMethods
    
    module ClassMethods
      # Generates all the attribute related methods for defined properties
      # accessors, mutators and query methods.
      def define_attribute_methods
        super(properties.keys)
      end
      
      def property(*args)
        super
        undefine_attribute_methods
      end
    end
    
    def method_missing(method_id, *args, &block)
      # If we haven't generated any methods yet, generate them, then
      # see if we've created the method we're looking for.
      unless self.class.attribute_methods_generated?
        self.class.define_attribute_methods
        method_name = method_id.to_s
        
        guard_private_attribute_method!(method_name, args)
        
        if self.class.generated_attribute_methods.method_defined?(method_name)
          return self.send(method_id, *args, &block)
        end
      end
      
      super
    end
    
    def respond_to?(*args)
      self.class.define_attribute_methods
      super
    end
    
    def clone_attribute_value(attribute_name)
      value = read_attribute(attribute_name)
      value.duplicable? ? value.clone : value
    rescue TypeError, NoMethodError
      value
    end
    
  protected
    def attribute_method?(attr_name)
      properties.has_key?(attr_name)
    end
  end
end
