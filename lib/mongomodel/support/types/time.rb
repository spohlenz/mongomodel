require 'active_support/core_ext/time/conversions'
require 'active_support/core_ext/string/conversions'

module MongoModel
  module Types
    class Time < Object
      def cast(value)
        time = value.to_time
        time.change(:usec => (time.usec / 1000.0).floor * 1000)
      rescue
        nil
      end
    end
  end
end
