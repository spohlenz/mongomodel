module MongoModel
  module AttributeMethods
    module MultiParameterAssignment
      extend ActiveSupport::Concern
      
      def assign_attributes(attrs, options={})#:nodoc:
        super(transform_multiparameter_attributes(attrs))
      end
    
    private
      # Converts multiparameter attributes into array format. For example, the parameters
      #   { "start_date(1i)" => "2010", "start_date(2i)" => "9", "start_date(3i)" => "4" }
      # will be converted to:
      #   { "start_date" => [2010, 9, 4] }
      def transform_multiparameter_attributes(attrs)
        attrs.merge(extract_multiparameter_attributes(attrs))
      end
      
      def extract_multiparameter_attributes(attrs)
        multiparameter_attributes = Hash.new { |h, k| h[k] = [] }
        
        attrs.each do |k, v|
          if k.to_s =~ /(.*)\((\d+)([if])?\)/
            multiparameter_attributes[$1][$2.to_i - 1] = type_cast_attribute_value($3, v)
            attrs.delete(k)
          end
        end
        
        multiparameter_attributes
      end
      
      def type_cast_attribute_value(type, value)
        case type
        when 'i', 'f'
          value.send("to_#{type}")
        else
          value
        end
      end
    end
  end
end
