require 'active_support/core_ext/date/conversions'
require 'active_support/core_ext/string/conversions'

module MongoModel
  module Types
    class Date < Object
      def cast(value)
        value.to_date if value.respond_to?(:to_date)
      end
    end
  end
end
