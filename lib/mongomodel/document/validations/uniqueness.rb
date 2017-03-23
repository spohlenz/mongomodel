require 'active_support/core_ext/array/wrap'

module MongoModel
  module DocumentExtensions
    module Validations
      class UniquenessValidator < ActiveModel::EachValidator
        def initialize(options)
          options = options.reverse_merge(:case_sensitive => true)

          ActiveSupport::Deprecation.silence { super }
          setup!(options[:class]) if options[:class] && !@klass
        end

        def setup(klass)
          setup!(klass)
        end

        def validate_each(record, attribute, value)
          finder_class = find_finder_class_for(record)
          unique_scope = finder_class.scoped

          if options[:case_sensitive] || !value.is_a?(String)
            unique_scope = unique_scope.where(attribute => value)
          else
            unique_scope = unique_scope.where("_lowercase_#{attribute}" => value.downcase)
          end

          Array.wrap(options[:scope]).each do |scope|
            unique_scope = unique_scope.where(scope => record.send(scope))
          end

          unique_scope = unique_scope.where(:id.ne => record.id) unless record.new_record?

          if unique_scope.any?
            record.errors.add(attribute, :taken, :message => options[:message], :value => value)
          end
        end

      private
        def setup!(klass)
          @klass = klass

          unless options[:index] == false
            # Create unique indexes to deal with race condition
            attributes.each do |attr_name|
              if options[:case_sensitive]
                klass.index *[attr_name] + Array.wrap(options[:scope]) << { :unique => true }
              else
                lowercase_key = "_lowercase_#{attr_name}"
                klass.before_save { attributes[lowercase_key] = send(attr_name).downcase }
                klass.index *[lowercase_key] + Array.wrap(options[:scope]) << { :unique => true }
              end
            end
          end
        end

        # The check for an existing value should be run from a class that
        # isn't abstract. This means working down from the current class
        # (self), to the first non-abstract class. Since classes don't know
        # their subclasses, we have to build the hierarchy between self and
        # the record's class.
        def find_finder_class_for(record) #:nodoc:
          class_hierarchy = [record.class]

          while class_hierarchy.first != @klass
            class_hierarchy.insert(0, class_hierarchy.first.superclass)
          end

          class_hierarchy.detect { |klass| !klass.abstract_class? }
        end
      end

      module ClassMethods
        # Validates whether the value of the specified attributes are unique across the system. Useful for making sure that only one user
        # can be named "davidhh".
        #
        #   class Person < MongoModel::Document
        #     validates_uniqueness_of :user_name, :scope => :account_id
        #   end
        #
        # It can also validate whether the value of the specified attributes are unique based on multiple scope parameters. For example,
        # making sure that a teacher can only be on the schedule once per semester for a particular class.
        #
        #   class TeacherSchedule < MongoModel::Document
        #     validates_uniqueness_of :teacher_id, :scope => [:semester_id, :class_id]
        #   end
        #
        # When the document is created, a check is performed to make sure that no document exists in the database with the given value for the specified
        # attribute (that maps to a property). When the document is updated, the same check is made but disregarding the document itself.
        #
        # Configuration options:
        # * <tt>:message</tt> - Specifies a custom error message (default is: "has already been taken").
        # * <tt>:scope</tt> - One or more properties by which to limit the scope of the uniqueness constraint.
        # * <tt>:case_sensitive</tt> - Looks for an exact match. Ignored by non-text columns (+true+ by default).
        # * <tt>:index</tt> - If set to false, disables the unique index constraint (default is +true+).
        # * <tt>:allow_nil</tt> - If set to true, skips this validation if the attribute is +nil+ (default is +false+).
        # * <tt>:allow_blank</tt> - If set to true, skips this validation if the attribute is blank (default is +false+).
        # * <tt>:if</tt> - Specifies a method, proc or string to call to determine if the validation should
        #   occur (e.g. <tt>:if => :allow_validation</tt>, or <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>). The
        #   method, proc or string should return or evaluate to a true or false value.
        # * <tt>:unless</tt> - Specifies a method, proc or string to call to determine if the validation should
        #   not occur (e.g. <tt>:unless => :skip_validation</tt>, or <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>). The
        #   method, proc or string should return or evaluate to a true or false value.
        #
        # === Concurrency and integrity
        #
        # Note that this validation method does not have the same race condition suffered by ActiveRecord and other ORMs.
        # A unique index is added to the collection to ensure that the collection never ends up in an invalid state.
        def validates_uniqueness_of(*attr_names)
          validates_with UniquenessValidator, _merge_attributes(attr_names)
        end
      end
    end
  end
end
