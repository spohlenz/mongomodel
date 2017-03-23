# MongoModel::InstrumentedCursor & MongoModel::InstrumentedCollection are wrappers
# around Mongo::Cursor & Mongo::Collection respectively to add in support for
# ActiveSupport notifications.
#
# They are primarily used in MongoModel to implement logging.
module MongoModel
  class InstrumentedCursor
    attr_reader :cursor

    def initialize(cursor)
      @cursor = cursor
    end

    def to_a
      instrument(query_description) do
        cursor.to_a
      end
    end

    def count
      instrument("count(#{cursor.selector.inspect})") do
        cursor.count
      end
    end

  private
    def method_missing(method, *args, &block)
      cursor.send(method, *args, &block)
    end

    def query_description
      "find(#{cursor.selector.inspect}, #{cursor.fields ? cursor.fields.inspect : '{}'})" +
      "#{cursor.skip != 0 ? ('.skip(' + cursor.skip.to_s + ')') : ''}#{cursor.limit != 0 ? ('.limit(' + cursor.limit.to_s + ')') : ''}" +
      "#{cursor.order ? ('.sort(' + cursor.order.inspect + ')') : ''}"
    end

    def instrument(query, &block)
      ActiveSupport::Notifications.instrument("query.mongomodel", :collection => cursor.collection.name, :query => query, &block)
    end
  end

  class InstrumentedCollection
    attr_reader :collection

    def initialize(collection)
      @collection = collection
    end

    def ==(other)
      case other
      when self.class
        collection == other.collection
      else
        collection == other
      end
    end

    def find(selector={}, options={})
      cursor = InstrumentedCursor.new(collection.find(selector, options))

      if block_given?
        yield cursor
        cursor.close
        nil
      else
        cursor
      end
    end

    def save(doc, options={})
      if doc.has_key?(:_id) || doc.has_key?('_id')
        selector = { '_id' => doc[:_id] || doc['_id'] }
        instrument("update(#{selector.inspect}, #{doc.inspect})") do
          collection.save(doc, options)
        end
      else
        instrument("insert(#{doc})") do
          collection.insert(doc, options)
        end
      end
    end

    def remove(selector={}, options={})
      instrument("remove(#{selector.inspect})") do
        collection.remove(selector, options)
      end
    end

    def update(selector, document, options={})
      instrument("update(#{selector.inspect}, #{document.inspect})") do
        collection.update(selector, document, options)
      end
    end

    def create_index(spec, options={})
      instrument("create_index(#{spec.inspect})") do
        collection.create_index(spec, options)
      end
    end

    def group(options, condition={}, initial={}, reduce=nil, finalize=nil)
      instrument("group(#{options.inspect})") do
        collection.group(options, condition, initial, reduce, finalize)
      end
    end

    def distinct(key, query=nil)
      instrument("distinct(#{key.inspect}#{query.present? ? ', ' + query.inspect : ''})") do
        collection.distinct(key, query)
      end
    end

    def map_reduce(map, reduce, options={})
      instrument("map_reduce(#{options.inspect})") do
        collection.map_reduce(map, reduce, options)
      end
    end

  private
    def method_missing(method, *args, &block)
      collection.send(method, *args, &block)
    end

    def instrument(query, &block)
      ActiveSupport::Notifications.instrument("query.mongomodel", :collection => collection.name, :query => query, &block)
    end
  end
end
