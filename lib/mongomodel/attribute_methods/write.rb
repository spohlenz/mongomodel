module MongoModel
  module AttributeMethods
    module Write
      extend ActiveSupport::Concern
      
      included do
        attribute_method_suffix "="
      end
      
      # Updates the attribute identified by <tt>name</tt> with the specified +value+.
      # Values are typecast to the appropriate type determined by the property.
      def write_attribute(name, value)
        attributes[name.to_sym] = value
      end
      
      # Updates the attribute identified by <tt>name</tt> with the specified +value+.
      # (Alias for the protected write_attribute method).
      def []=(name, value)
        write_attribute(name, value)
      end
      
    private
      # Handle *= for method_missing.
      def attribute=(attribute_name, value)
        write_attribute(attribute_name, value)
      end
    end
  end
end
