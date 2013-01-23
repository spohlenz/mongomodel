require 'active_support/core_ext/date_time/conversions'
require 'active_support/core_ext/string/conversions'

module MongoModel
  module Types
    class DateTime < Object
      def cast(value)
        case value
        when ::Array
          ::DateTime.civil(*value)
        when ::Hash
          cast("#{value[:date]} #{value[:time]}")
        when ::String
          cast(::DateTime.parse(value))
        else
          value.to_datetime.change(:usec => 0)
        end
      rescue
        nil
      end
      
      def to_mongo(value)
        to_time(value.utc) if value
      end
      
      def from_mongo(value)
        time = value.respond_to?(:in_time_zone) ? value.in_time_zone : value
        time.to_datetime
      end
    
    private
      # Define our own to_time method as DateTime.to_time in ActiveSupport may return
      # the DateTime object unchanged, whereas BSON expects an actual Time object.
      def to_time(dt)
        ::Time.utc(dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec)
      end
    end
  end
end

MongoModel::Types.register_converter(DateTime, MongoModel::Types::DateTime.new)
