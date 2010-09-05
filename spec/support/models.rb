class CustomClass
  attr_reader :name
  
  def initialize(name)
    @name = name
  end
  
  def ==(other)
    other.is_a?(self.class) && name == other.name
  end
  
  def to_mongo
    { :name => name }
  end
  
  def self.from_mongo(hash)
    new(hash[:name])
  end
  
  def self.cast(value)
    new(value.to_s)
  end
end

class CustomClassWithDefault < CustomClass
  def self.mongomodel_default(doc)
    new("Custom class default")
  end
end
