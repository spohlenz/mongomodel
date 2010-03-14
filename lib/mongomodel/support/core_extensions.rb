class Boolean < TrueClass; end

class Symbol
  [:lt, :lte, :gt, :gte, :ne, :in, :nin, :mod, :all, :size, :exists].each do |operator|
    define_method(operator) { MongoModel::MongoOperator.new(self, operator) }
  end
  
  define_method(:asc) { MongoModel::MongoOrder::Clause.new(self, :ascending) }
  define_method(:desc) { MongoModel::MongoOrder::Clause.new(self, :descending) }
end
