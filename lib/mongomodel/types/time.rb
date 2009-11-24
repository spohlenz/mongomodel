require 'active_support/core_ext/time/conversions'
require 'active_support/core_ext/string/conversions'

module MongoModel
  module Types
    class Time < Object
      def cast(value)
        value.to_time rescue nil
      end
    end
  end
end
