require 'rational' unless RUBY_VERSION >= '1.9.2'

module MongoModel
  module Types
    class Rational < Object
      if RUBY_VERSION >= '1.9.2'
        def cast(value)
          Rational(value)
        end
      else
        def cast(value)
          case value
          when ::Rational
            value
          when ::String
            rational_from_string(value)
          else
            Rational(value)
          end
        end
      end

      def from_mongo(value)
        rational_from_string(value)
      end

      def to_mongo(value)
        value.to_s
      end

    private
      if RUBY_VERSION >= '1.9.2'
        def rational_from_string(str)
          Rational(str)
        end
      else
        def rational_from_string(str)
          numerator, denominator = str.split("/", 2)
          Rational(numerator.to_i, (denominator || 1).to_i)
        end
      end
    end
  end
end

MongoModel::Types.register_converter(Rational, MongoModel::Types::Rational.new)
