module MongoModel
  module AttributeMethods
    module Nested
      extend ActiveSupport::Concern
      
      included do
        class_attribute :nested_attributes_options, :instance_writer => false
        self.nested_attributes_options = {}
      end
      
      module ClassMethods
        def accepts_nested_attributes_for(*attr_names)
          options = attr_names.extract_options!
          
          attr_names.each do |attr_name|
            type = property_type(attr_name)
            
            nested_attributes_options = self.nested_attributes_options.dup
            nested_attributes_options[attr_name.to_sym] = options
            self.nested_attributes_options = nested_attributes_options
            
            class_eval <<-EORUBY, __FILE__, __LINE__ + 1
              if method_defined?(:#{attr_name}_attributes=)
                remove_method(:#{attr_name}_attributes=)
              end
              
              def #{attr_name}_attributes=(attributes)
                assign_nested_attributes_for_#{type}(:#{attr_name}, attributes)
              end
            EORUBY
          end
        end
      
      private
        def property_type(attr_name)
          if property = properties[attr_name]
            property.type <= Array ? :collection : :property
          elsif association = associations[attr_name]
            association.collection? ? :association_collection : :association
          end
        end
      end
    
    private
      def assign_nested_attributes_for_property(property, attributes)
        if obj = send(property)
          obj.attributes = attributes
        else
          send("#{property}=", attributes)
        end
      end
      
      def assign_nested_attributes_for_collection(property, attributes_collection)
        attributes_collection = convert_to_array(attributes_collection)
        options = self.nested_attributes_options[property]
        
        if options[:limit] && attributes_collection.size > options[:limit]
          raise TooManyDocuments, "Maximum #{options[:limit]} documents are allowed. Got #{attributes_collection.size} documents instead."
        end
        
        collection = send(property)
        collection.clear if options[:clear]
        
        attributes_collection.each_with_index do |attributes, index|
          if collection[index]
            collection[index].attributes = attributes
          else
            collection[index] = attributes
          end
        end
      end
      
      def assign_nested_attributes_for_association(association, attributes)
        if obj = send(association)
          obj.attributes = attributes
        else
          send("build_#{association}", attributes)
        end
      end
      
      def assign_nested_attributes_for_association_collection(association, attributes_collection)
        attributes_collection = convert_to_array(attributes_collection)
        options = self.nested_attributes_options[association]
        
        if options[:limit] && attributes_collection.size > options[:limit]
          raise TooManyDocuments, "Maximum #{options[:limit]} documents are allowed. Got #{attributes_collection.size} documents instead."
        end
        
        association = send(association)
        association.clear if options[:clear]
        
        attributes_collection.each do |attributes|
          association.build(attributes)
        end
      end
      
      def convert_to_array(params)
        case params
        when Hash
          params.sort.map(&:last)
        else
          Array(params)
        end
      end
    end
  end
end
