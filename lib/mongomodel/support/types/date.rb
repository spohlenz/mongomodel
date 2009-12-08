require 'active_support/core_ext/date/conversions'
require 'active_support/core_ext/string/conversions'

module MongoModel
  module Types
    class Date < Object
      def cast(value)
        value.to_date rescue nil
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
