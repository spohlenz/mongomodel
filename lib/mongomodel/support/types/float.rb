module MongoModel
  module Types
    class Float < Object
      def cast(value)
        if value.nil?
          nil
        else
          Kernel::Float(value) rescue nil
        end
      end
      
      def boolean(value)
        !value.zero?
      end
    end
  end
end
