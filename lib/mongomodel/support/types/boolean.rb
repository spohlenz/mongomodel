module MongoModel
  module Types
    class Boolean < Object
      TRUE_VALUES = [ true, 'true', 't', 'TRUE', 'T', 'YES', 'y', '1', 1 ]
      FALSE_VALUES = [ false, 'false', 'f', 'FALSE', 'F', 'NO', 'n', '0', 0 ]
      
      def cast(value)
        if true?(value)
          true
        elsif false?(value)
          false
        end
      end
    
    private
      def true?(value)
        TRUE_VALUES.include?(value)
      end
      
      def false?(value)
        FALSE_VALUES.include?(value)
      end
    end
  end
end
