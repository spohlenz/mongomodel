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
          round_microseconds(value.to_datetime.utc) if value
        end
      rescue
        nil
      end
      
      def to_mongo(value)
        to_time(value.utc) if value
      end
      
      def from_mongo(t)
        ::DateTime.civil(t.year, t.month, t.day, t.hour, t.min, t.sec + Rational(t.usec, 1000000)) if t
      end
    
    private
      # Define our own to_time method as DateTime.to_time in ActiveSupport may return
      # the DateTime object unchanged, whereas BSON expects an actual Time object.
      def to_time(dt)
        ::Time.utc(dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec, sec_fraction(dt).to_f * 1000000)
      end
      
      def sec_fraction(dt)
        if RUBY_VERSION <= "1.8.7"
          # Ruby 1.8.7 DateTime#sec_fraction unit is in days
          dt.sec_fraction * 86400
        else
          dt.sec_fraction
        end
      end
      
      def round_microseconds(dt)
        seconds = dt.sec + sec_fraction(dt)
        dt.change(:sec => Rational((seconds * 1000).round, 1000))
      end
    end
  end
end

MongoModel::Types.register_converter(DateTime, MongoModel::Types::DateTime.new)
