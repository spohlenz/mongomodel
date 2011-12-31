require 'mongomodel/support/types/object'
require 'mongomodel/support/types/custom'

module MongoModel
  module Types
    CONVERTERS = {}
    
    def self.register_converter(klass, converter)
      CONVERTERS[klass] = converter.new
    end
    
    def self.converter_for(type)
      if CONVERTERS[type]
        CONVERTERS[type]
      else
        CONVERTERS[type] = Types::Custom.new(type)
      end
    end
  end
end

# Built-in types
require 'mongomodel/support/types/string'
require 'mongomodel/support/types/integer'
require 'mongomodel/support/types/float'
require 'mongomodel/support/types/boolean'
require 'mongomodel/support/types/symbol'
require 'mongomodel/support/types/date'
require 'mongomodel/support/types/time'
require 'mongomodel/support/types/date_time'
require 'mongomodel/support/types/array'
require 'mongomodel/support/types/set'
require 'mongomodel/support/types/hash'
require 'mongomodel/support/types/rational'
require 'mongomodel/support/types/openstruct'
