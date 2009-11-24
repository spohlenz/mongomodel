module MongoModel
  module Attributes
    module Mongo
      def to_mongo
        inject({}) do |result, (k, v)|
          property = properties[k]
          
          if property
            result[property.as] = property.to_mongo(v)
          else
            converter = Types.converter_for(v.class)
            result[k.to_s] = converter.to_mongo(v)
          end
          
          result
        end
      end
      
      def from_mongo!(hash)
        hash.each do |k, v|
          property = properties_as[k.to_s]
          
          if property
            self[property.name] = property.from_mongo(v)
          else
            self[k.to_sym] = v
          end
        end
      end
    
    private
      def properties_as
        @properties_as ||= properties.inject({}) do |result, (name, property)|
          result[property.as] = property
          result
        end
      end
    end
  end
end