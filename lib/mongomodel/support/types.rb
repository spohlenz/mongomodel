require 'rational' unless RUBY_VERSION >= '1.9.2'
require 'set'

require 'mongomodel/support/types/object'
require 'mongomodel/support/types/string'
require 'mongomodel/support/types/integer'
require 'mongomodel/support/types/float'
require 'mongomodel/support/types/boolean'
require 'mongomodel/support/types/symbol'
require 'mongomodel/support/types/date'
require 'mongomodel/support/types/time'
require 'mongomodel/support/types/date_time'
require 'mongomodel/support/types/custom'
require 'mongomodel/support/types/array'
require 'mongomodel/support/types/set'
require 'mongomodel/support/types/hash'
require 'mongomodel/support/types/rational'

module MongoModel
  module Types
    CONVERTERS = {
      ::String   => Types::String.new,
      ::Integer  => Types::Integer.new,
      ::Float    => Types::Float.new,
      ::Boolean  => Types::Boolean.new,
      ::Symbol   => Types::Symbol.new,
      ::Date     => Types::Date.new,
      ::Time     => Types::Time.new,
      ::DateTime => Types::DateTime.new,
      ::Array    => Types::Array.new,
      ::Set      => Types::Set.new,
      ::Hash     => Types::Hash.new,
      ::Rational => Types::Rational.new,
      ::OpenStruct => Types::OpenStruct.new
    }
    
    def self.converter_for(type)
      if CONVERTERS[type]
        CONVERTERS[type]
      else
        CONVERTERS[type] = Types::Custom.new(type)
      end
    end
  end
end
