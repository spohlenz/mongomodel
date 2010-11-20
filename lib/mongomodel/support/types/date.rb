require 'active_support/core_ext/date/conversions'
require 'active_support/core_ext/string/conversions'

module MongoModel
  module Types
    class Date < Object
      def cast(value)
        case value
        when ::Array
          ::Date.new(*value)
        else
          value.to_date
        end
      rescue
        nil
      end
      
      def to_mongo(value)
        value.strftime("%Y/%m/%d") if value
      end
      
      def from_mongo(value)
        value.to_date if value
      end
    end
  end
end
