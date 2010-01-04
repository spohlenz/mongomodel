require 'active_support/core_ext/hash/keys'

module MongoModel
  module DocumentExtensions
    module Finders
      def find(*args)
        options = args.extract_options!
      
        case args.first
        when :first then find_first(options)
        when :last then  find_last(options)
        when :all then   find_all(options)
        else             find_by_ids(args, options)
        end
      end
    
      def first(options={})
        find(:first, options)
      end
    
      def last(options={})
        find(:last, options)
      end
    
      def all(options={})
        find(:all, options)
      end
    
      def count(conditions={})
        _find(:conditions => conditions).count
      end
    
      def exists?(id_or_conditions)
        case id_or_conditions
        when String
          exists?(:id => id_or_conditions)
        else
          count(id_or_conditions) > 0
        end
      end
  
    private
      def find_first(options={})
        _find_and_instantiate(options.merge(:limit => 1)).first
      end
    
      def find_last(options={})
        order = MongoOrder.parse(options[:order]) || :id.asc
        _find_and_instantiate(options.merge(:order => order.reverse, :limit => 1)).first
      end
    
      def find_all(options={})
        _find_and_instantiate(options)
      end
    
      def find_by_ids(ids, options={})
        ids.flatten!
      
        case ids.size
        when 0
          raise ArgumentError, "At least one id must be specified"
        when 1
          id = ids.first.to_s
          _find_and_instantiate(options.deep_merge(:conditions => { :id => id })).first || raise(DocumentNotFound, "Couldn't find document with id: #{id}")
        else
          docs = _find_and_instantiate(options.deep_merge(:conditions => { :id.in => ids.map { |id| id.to_s } }))
          raise DocumentNotFound if docs.size != ids.size
          docs.sort_by { |doc| ids.index(doc.id) }
        end
      end
    
      def _find(options={})
        selector, options = MongoOptions.new(self, options).to_a
        collection.find(selector, options)
      end
    
      def _find_and_instantiate(options={})
        _find(options).to_a.map { |doc| from_mongo(doc) }
      end
    end
  end
end
