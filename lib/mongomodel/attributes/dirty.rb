module MongoModel
  module Attributes
    module Dirty
      def []=(key, value)
        attr = key.to_s
        
        # The attribute already has an unsaved change.
        if changed.include?(attr)
          old = changed[attr]
          changed.delete(attr) if value == old
        else
          old = clone_attribute_value(attr)
          changed[attr] = old unless value == old
        end
        
        super
      end
      
      def changed
        @changed ||= {}
      end
      
    private
      def clone_attribute_value(attribute_name)
        value = self[attribute_name.to_sym]
        value.duplicable? ? value.clone : value
      rescue TypeError, NoMethodError
        value
      end
    end
  end
end
