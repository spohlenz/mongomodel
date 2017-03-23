class SymbolOperator
  def to_mongo_operator
    MongoModel::MongoOperator.new(field, operator)
  end

  def to_mongo_order_clause
    MongoModel::MongoOrder::Clause.new(field, operator.to_s == 'asc' ? :ascending : :descending)
  end

  def eql?(other)
    self == other
  end

  def hash
    field.hash ^ operator.hash
  end
end

class NilClass
  def to_mongo(value=nil)
    value
  end
end
