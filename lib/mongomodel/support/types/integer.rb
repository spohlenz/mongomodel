module MongoModel
  module Types
    class Integer < Object
      def cast(value)
        if value.nil?
          nil
        else
          begin
            Kernel::Integer(value)
          rescue ArgumentError
            Kernel::Float(value).to_i rescue nil
          end
        end
      end
      
      def boolean(value)
        !value.zero?
      end
    end
  end
end

MongoModel::Types.register_converter(Integer, MongoModel::Types::Integer)
