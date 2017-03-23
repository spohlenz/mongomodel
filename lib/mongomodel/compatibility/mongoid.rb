class Origin::Key
  def to_mongo_operator
    MongoModel::MongoOperator.new(name, operator.sub(/^\$/, ""))
  end

  def to_mongo_order_clause
    MongoModel::MongoOrder::Clause.new(name, operator == 1 ? :ascending : :descending)
  end

  def eql?(other)
    self == other
  end

  def hash
    name.hash ^ operator.hash
  end
end
