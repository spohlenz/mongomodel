module MongoModel::MapReduce
  extend ActiveSupport::Concern

  include MongoModel::DocumentExtensions::Scopes

  included do
    class_attribute :parent_collection
  end

  module ClassMethods
    def from_mongo(attrs)
      new(attrs['_id'], attrs['value'])
    end

    def cached
      from(collection_name)
    end

    def database
      parent_collection.db
    end

    def collection
      parent_collection.map_reduce(map_function, reduce_function, map_reduce_options)
    end

    def collection_name
      @_collection_name || default_collection_name
    end

    def collection_name=(name)
      @_collection_name = name
    end

    def default_collection_name
      [parent_collection.name, name.demodulize.tableize.gsub(/\//, '.')].join("._")
    end

    def map_function
      raise NotImplementedError, "map_function is not implemented"
    end

    def reduce_function
      raise NotImplementedError, "reduce_function is not implemented"
    end

    def map_reduce_options
      { :out => collection_name }
    end
  end
end
