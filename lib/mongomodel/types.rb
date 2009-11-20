require 'mongomodel/types/object'
require 'mongomodel/types/string'
require 'mongomodel/types/integer'
require 'mongomodel/types/float'
require 'mongomodel/types/boolean'
require 'mongomodel/types/symbol'
require 'mongomodel/types/date'
require 'mongomodel/types/time'
require 'mongomodel/types/custom'
require 'mongomodel/types/array'
require 'mongomodel/types/hash'

module MongoModel
  module Types
    CONVERTERS = {
      ::String  => Types::String.new,
      ::Integer => Types::Integer.new,
      ::Float   => Types::Float.new,
      ::Boolean => Types::Boolean.new,
      ::Symbol  => Types::Symbol.new,
      ::Date    => Types::Date.new,
      ::Time    => Types::Time.new,
      ::Array   => Types::Array.new,
      ::Hash    => Types::Hash.new
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
