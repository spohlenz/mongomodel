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
      
      def attributes=(attrs)#:nodoc:
        super(sanitize_for_mass_assignment(attrs))
      end
    end
  end
end
