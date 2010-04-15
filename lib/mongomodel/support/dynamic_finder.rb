module MongoModel
  class DynamicFinder
    def initialize(scope, attribute_names, finder=:first, bang=false)
      @scope, @attribute_names, @finder, @bang = scope, attribute_names, finder, bang
    end
    
    def execute(*args)
      options = args.extract_options!
      conditions = build_conditions(args)
      
      result = @scope.where(conditions).send(instantiator? ? :first : @finder)
      
      if result.nil?
        if bang?
          raise DocumentNotFound, "Couldn't find #{@scope.klass.to_s} with #{conditions.inspect}"
        elsif instantiator?
          return @scope.send(@finder, conditions)
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
    
    def self.match(scope, method)
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
      if names.all? { |n| scope.klass.properties.include?(n.to_sym) }
        new(scope, names, finder, bang)
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
