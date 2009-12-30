module MongoModel
  module DocumentExtensions
    module DynamicFinders
      def respond_to?(method_id, include_private = false)
        if DynamicFinder.match(self, method_id)
          true
        else
          super
        end
      end
      
      def method_missing(method_id, *args, &block)
        if finder = DynamicFinder.match(self, method_id)
          finder.execute(*args)
        else
          super
        end
      end
    end
    
    class DynamicFinder
      def initialize(model, attribute_names, finder=:first, bang=false)
        @model, @attribute_names, @finder, @bang = model, attribute_names, finder, bang
      end
      
      def execute(*args)
        options = args.extract_options!
        conditions = build_conditions(args)
        
        result = @model.send(instantiator? ? :first : @finder, options.deep_merge(:conditions => conditions))
        
        if result.nil?
          if bang?
            raise DocumentNotFound, "Couldn't find #{@model.to_s} with #{conditions.inspect}"
          elsif instantiator?
            return @model.send(@finder, conditions)
          end
        end
        
        result
      end
      
      def bang?
        @bang
      end
      
      def instantiator?
        @finder == :new || @finder == :create
      end
      
      def self.match(model, method)
        finder = :first
        bang = false
        
        case method.to_s
        when /^find_(all_by|last_by|by)_([_a-zA-Z]\w*)$/
          finder = :last if $1 == 'last_by'
          finder = :all if $1 == 'all_by'
          names = $2
        when /^find_by_([_a-zA-Z]\w*)\!$/
          bang = true
          names = $1
        when /^find_or_(initialize|create)_by_([_a-zA-Z]\w*)$/
          finder = ($1 == 'initialize' ? :new : :create)
          names = $2
        else
          return nil
        end
        
        names = names.split('_and_')
        if names.all? { |n| model.properties.include?(n.to_sym) }
          new(model, names, finder, bang)
        end
      end
    
    private
      def build_conditions(args)
        result = {}
        
        @attribute_names.zip(args) do |attribute, value|
          result[attribute.to_sym] = value
        end
        
        result
      end
    end
  end
end
