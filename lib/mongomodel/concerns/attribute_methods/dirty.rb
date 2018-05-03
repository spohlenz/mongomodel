module MongoModel
  module AttributeMethods
    module Dirty
      extend ActiveSupport::Concern

      include ActiveModel::AttributeMethods

      OPTION_NOT_GIVEN = Object.new
      private_constant :OPTION_NOT_GIVEN

      included do
        attribute_method_suffix "_changed?", "_change", "_will_change!", "_was"
        attribute_method_suffix "_previously_changed?", "_previous_change"
        attribute_method_affix prefix: "restore_", suffix: "!"

        before_save { @previously_changed = changes }
        after_save { changed_attributes.clear }
      end

      def changed?
        changed_attributes.present?
      end

      def changed
        changed_attributes.keys
      end

      def changes
        ActiveSupport::HashWithIndifferentAccess[changed.map { |attr| [attr, attribute_change(attr)] }]
      end

      def previous_changes
        @previously_changed ||= ActiveSupport::HashWithIndifferentAccess.new
      end

      def changed_attributes
        @changed_attributes ||= ActiveSupport::HashWithIndifferentAccess.new
      end

      def attribute_changed?(attr, from: OPTION_NOT_GIVEN, to: OPTION_NOT_GIVEN)
        !!changes_include?(attr) &&
          (to == OPTION_NOT_GIVEN || to == __send__(attr)) &&
          (from == OPTION_NOT_GIVEN || from == changed_attributes[attr])
      end

      def attribute_was(attr)
        attribute_changed?(attr) ? changed_attributes[attr] : __send__(attr)
      end

      def attribute_previously_changed?(attr)
        previous_changes.include?(attr)
      end

      def restore_attributes(attributes = changed)
        attributes.each { |attr| restore_attribute! attr }
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

    private
      def changes_include?(attr_name)
        attributes_changed_by_setter.include?(attr_name)
      end
      alias attribute_changed_by_setter? changes_include?

      def attribute_change(attr)
        [changed_attributes[attr], __send__(attr)] if attribute_changed?(attr)
      end

      def attribute_previous_change(attr)
        previous_changes[attr] if attribute_previously_changed?(attr)
      end

      def attribute_will_change!(attr)
        return if attribute_changed?(attr)

        begin
          value = __send__(attr)
          value = value.duplicable? ? value.clone : value
        rescue TypeError, NoMethodError
        end

        set_attribute_was(attr, value)
      end

      def restore_attribute!(attr)
        if attribute_changed?(attr)
          __send__("#{attr}=", changed_attributes[attr])
          clear_attribute_changes([attr])
        end
      end

      alias_method :attributes_changed_by_setter, :changed_attributes

      def set_attribute_was(attr, old_value)
        attributes_changed_by_setter[attr] = old_value
      end

      def clear_attribute_changes(attributes)
        attributes_changed_by_setter.except!(*attributes)
      end

      def clone_attribute_value(attribute_name)
        value = self[attribute_name.to_sym]
        value.duplicable? ? value.clone : value
      rescue TypeError, NoMethodError
        value
      end
    end
  end
end
