require 'active_support/core_ext/time/conversions'
require 'active_support/core_ext/time/zones'
require 'active_support/core_ext/string/conversions'

module MongoModel
  module Types
    class Time < Object
      def cast(value)
        case value
        when ::Array
          base = ::Time.zone ? ::Time.zone : ::Time
          base.local(*value)
        when ::String
          base = ::Time.zone ? ::Time.zone : ::Time
          cast(base.parse(value))
        when ::Hash
          cast("#{value[:date]} #{value[:time]}")
        else
          time = value.to_time.in_time_zone
          time.change(:usec => (time.usec / 1000.0).floor * 1000)
        end
      rescue
        nil
      end
      
      def to_mongo(value)
        value.utc if value
      end
      
      def from_mongo(value)
        value.in_time_zone if value
      end
    end
  end
end

MongoModel::Types.register_converter(Time, MongoModel::Types::Time.new)
