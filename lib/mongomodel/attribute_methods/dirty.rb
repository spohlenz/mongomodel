module MongoModel
  module AttributeMethods
    module Dirty
      extend ActiveSupport::Concern
      
      include ActiveModel::Dirty
      
      module DocumentExtensions
        extend ActiveSupport::Concern
        
        included do
          after_save { changed_attributes.clear }
        end
      end
      
      # Returns the attributes as they were before any changes were made to the document.
      def original_attributes
        attributes.merge(changed_attributes)
      end
      
      # Wrap write_attribute to remember original attribute value.
      def write_attribute(attr, value)
        attr = attr.to_sym
          
        # The attribute already has an unsaved change.
        if changed_attributes.include?(attr)
          old = changed_attributes[attr]
          changed_attributes.delete(attr) if value == old
        else
          old = clone_attribute_value(attr)
          changed_attributes[attr] = old unless value == old
        end
        
        # Carry on.
        super
      end
    end
  end
end
