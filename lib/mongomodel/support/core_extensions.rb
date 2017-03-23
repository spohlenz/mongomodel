class Boolean; end unless defined?(Boolean)

class Symbol
  [:lt, :lte, :gt, :gte, :ne, :in, :nin, :mod, :all, :size, :exists, :near].each do |operator|
    define_method(operator) { MongoModel::MongoOperator.new(self, operator) } unless method_defined?(operator)
  end

  define_method(:asc) { MongoModel::MongoOrder::Clause.new(self, :ascending) } unless method_defined?(:asc)
  define_method(:desc) { MongoModel::MongoOrder::Clause.new(self, :descending) } unless method_defined?(:desc)
end
