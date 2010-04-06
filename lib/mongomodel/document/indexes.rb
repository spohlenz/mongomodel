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
        
        def index(*args)
          index = Index.new(*args)
          indexes << index
          @_indexes_initialized = false
          index
        end

        def indexes
          read_inheritable_attribute(:indexes) || write_inheritable_attribute(:indexes, [])
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

      private
        def _find(*)
          ensure_indexes! unless indexes_initialized?
          super
        end
      end
    end
  end
  
  class Index
    def initialize(*keys)
      options = keys.extract_options!
      @unique = options.delete(:unique)
      
      keys.each do |key|
        self.keys[key.to_sym] = :ascending
      end
      
      options.each do |key, order|
        self.keys[key.to_sym] = order
      end
    end
    
    def keys
      @keys ||= OrderedHash.new
    end
    
    def unique?
      @unique
    end
    
    def to_args
      args = []
      
      if keys.size == 1 && keys.all? { |k, o| o == :ascending }
        args << keys.keys.first
      else
        args << keys.map { |k, o| [k, o == :ascending ? 1 : -1] }.sort_by { |k| k.first.to_s }
      end
        
      args << { :unique => true } if unique?
      
      args
    end
    
    def ==(other)
      other.is_a?(Index) && to_args == other.to_args
    end
  end
end
