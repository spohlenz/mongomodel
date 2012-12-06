module MongoModel
  module AttributeMethods
    module Read
      extend ActiveSupport::Concern
      
      # ActiveModel 3.2 defines the non-prefixed attribute name automatically
      if ActiveModel::VERSION::STRING <= "3.2"
        included do
          attribute_method_suffix ""
        end
      end
      
      # Returns the value of the attribute identified by +name+ after it has been typecast (for example,
      # "2004-12-12" in a date property is cast to a date object, like Date.new(2004, 12, 12)).
      def read_attribute(name)
        attributes[name.to_sym]
      end
      
      # Returns the value of the attribute identified by <tt>name</tt> after it has been typecast (for example,
      # "2004-12-12" in a date property is cast to a date object, like Date.new(2004, 12, 12)).
      # (Alias for read_attribute).
      def [](name)
        read_attribute(name)
      end
    
    private
      def attribute(attribute_name)
        read_attribute(attribute_name)
      end
    end
  end
end
