require 'active_support/core_ext/date/conversions'
require 'active_support/core_ext/string/conversions'

module MongoModel
  module Types
    class Date < Object
      def cast(value)
        value.to_date rescue nil
      end
    end
  end
end
