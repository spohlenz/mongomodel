module MongoModel
  module AttributeMethods
    module Dirty
      extend ActiveSupport::Concern

      include ActiveModel::Dirty

      included do
        before_save { @previously_changed = changes }
        after_save { changed_attributes.clear }
      end

      def write_attribute(key, value)
        attr = key.to_sym

        # The attribute already has an unsaved change.
        if changed_attributes.include?(attr)
          old = changed_attributes[attr]
          changed_attributes.delete(attr) if value == old
        else
          old = clone_attribute_value(attr)
          changed_attributes[attr] = old unless value == old
        end

        super
      end

      # Returns the attributes as they were before any changes were made to the document.
      def original_attributes
        {}.with_indifferent_access.merge(attributes).merge(changed_attributes)
      end

    protected
      def changed_attributes
        @changed_attributes ||= {}.with_indifferent_access
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
