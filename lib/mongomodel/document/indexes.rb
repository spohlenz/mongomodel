require 'active_support/core_ext/array/extract_options'

module MongoModel
  module DocumentExtensions
    module Indexes
      extend ActiveSupport::Concern
      
      included do
        index :_type
      end
      
      module ClassMethods
        def property(name, *args, &block) #:nodoc:
          property = super
          index(name) if property.options[:index]
          property
        end
        
        def indexes
          @_indexes ||= []
        end
        
        def indexes=(indexes)
          @_indexes = indexes
        end
        
        def index(*args)
          index = Index.new(*args)
          self.indexes << index
          @_indexes_initialized = false
          index
        end

        def indexes_initialized?
          @_indexes_initialized == true
        end

        def ensure_indexes!
          indexes.each do |index|
            collection.create_index(*index.to_args)
          end

          @_indexes_initialized = true
        end
        
        def inherited(subclass)
          super
          subclass.indexes = indexes.dup
        end
      end
    end
  end
  
  class Index
    def initialize(*keys)
      options = keys.extract_options!
      
      @name   = options.delete(:name)
      @unique = options.delete(:unique)
      @min    = options.delete(:min)
      @max    = options.delete(:max)
      
      keys.each do |key|
        self.keys[key.to_sym] = :ascending
      end
      
      options.each do |key, order|
        self.keys[key.to_sym] = order
      end
    end
    
    def keys
      @keys ||= ActiveSupport::OrderedHash.new
    end
    
    def unique?
      @unique
    end
    
    def geo2d?
      @geo2d ||= keys.size == 1 && keys.values.first == :geo2d
    end
    
    def to_args
      args = []
      options = {}
      
      if geo2d?
        args << [[keys.keys.first, Mongo::GEO2D]]
      elsif keys.size == 1 && keys.values.first == :ascending
        args << keys.keys.first
      else
        args << keys.map { |k, o| [k, o == :ascending ? Mongo::ASCENDING : Mongo::DESCENDING] }.sort_by { |k| k.first.to_s }
      end
      
      if geo2d? && @min && @max
        options[:min] = @min
        options[:max] = @max
      end
      
      options[:unique] = true if unique?
      options[:name] = @name if @name
      
      args << options if options.any?
      args
    end
    
    def ==(other)
      other.is_a?(Index) && to_args == other.to_args
    end
  end
end
