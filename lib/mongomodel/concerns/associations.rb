module MongoModel
  module Associations
    extend ActiveSupport::Concern

    def associations
      @_associations ||= self.class.associations.inject({}) do |result, (name, association)|
        result[name] = association.for(self)
        result
      end
    end

    module ClassMethods
      def associations
        @_associations ||= {}
      end

      def associations=(associations)
        @_associations = associations
      end

      def belongs_to(name, options={})
        associations[name] = create_association(BelongsTo, name, options)
      end

      def has_many(name, options={})
        associations[name] = create_association(has_many_type(options), name, options)
      end

      def inherited(subclass)
        super
        subclass.associations = associations.dup
      end

    private
      def has_many_type(options)
        case options[:by]
        when :ids
          HasManyByIds
        when :foreign_key
          HasManyByForeignKey
        else
          ancestors.include?(Document) ? HasManyByForeignKey : HasManyByIds
        end
      end

      def create_association(type, name, options={})
        type.new(self, name, options).define!
      end
    end
  end
end
