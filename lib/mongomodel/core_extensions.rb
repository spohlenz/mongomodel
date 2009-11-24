class Boolean < TrueClass; end

class Symbol
  [:lt, :lte, :gt, :gte, :ne, :in, :nin, :mod, :all, :size, :exists].each do |operator|
    define_method(operator) { MongoModel::FinderOperator.new(self, operator) }
  end
  
  [:asc, :desc].each do |order|
    define_method(order) { "#{self} #{order}" }
  end
end
