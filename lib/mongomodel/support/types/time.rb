require 'active_support/core_ext/time/conversions'
require 'active_support/core_ext/string/conversions'

module MongoModel
  module Types
    class Time < Object
      def cast(value)
        time = value.to_time.utc
        # BSON only stores time accurate to the millisecond
        ::Time.at((time.to_f * 1000).floor / 1000.0)
      rescue
        nil
      end
    end
  end
end
