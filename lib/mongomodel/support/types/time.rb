require 'active_support/core_ext/time/conversions'
require 'active_support/core_ext/string/conversions'

module MongoModel
  module Types
    class Time < Object
      def cast(value)
        case value
        when ::Array
          base = ::Time.zone ? ::Time.zone : ::Time
          base.local(*value)
        else
          time = value.to_time
          time.change(:usec => (time.usec / 1000.0).floor * 1000)
        end
      rescue
        nil
      end
      
      def to_mongo(value)
        value.utc if value
      end
      
      def from_mongo(value)
        value.respond_to?(:in_time_zone) ? value.in_time_zone : value
      end
    end
  end
end
