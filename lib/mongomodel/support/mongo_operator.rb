module MongoModel
  class MongoOperator
    attr_reader :field, :operator
    
    def initialize(field, operator)
      @field, @operator = field, operator
    end
    
    def to_mongo_selector(value)
      { "$#{operator}" => value }
    end
    
    def inspect
      "#{field.inspect}.#{operator}"
    end
    
    def ==(other)
      other.is_a?(self.class) && field == other.field && operator == other.operator
    end
    
    def hash
      field.hash ^ operator.hash
    end
    
    def eql?(other)
      self == other
    end
  end
end
