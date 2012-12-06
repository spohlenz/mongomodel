module MongoModel
  module AttributeMethods
    module Protected
      extend ActiveSupport::Concern
      
      include ActiveModel::MassAssignmentSecurity

      module ClassMethods
        def property(name, *args, &block)#:nodoc:
          property = super(name, *args, &block)

          attr_protected(name) if property.options[:protected]
          attr_accessible(name) if property.options[:accessible]
          
          property
        end
      end
      
      def assign_attributes(attrs, options={})
        if options[:without_protection]
          super
        else
          super(sanitize_for_mass_assignment(attrs, options[:as] || :default))
        end
      end
    end
  end
end
