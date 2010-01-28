class Boolean < TrueClass; end

class Symbol
  [:lt, :lte, :gt, :gte, :ne, :in, :nin, :mod, :all, :size, :exists].each do |operator|
    define_method(operator) { MongoModel::MongoOperator.new(self, operator) }
  end
  
  define_method(:asc) { MongoModel::MongoOrder::Clause.new(self, :ascending) }
  define_method(:desc) { MongoModel::MongoOrder::Clause.new(self, :descending) }
end

class Object
  begin
    ObjectSpace.each_object(Class.new) {}

    # Exclude this class unless it's a subclass of our supers and is defined.
    # We check defined? in case we find a removed class that has yet to be
    # garbage collected. This also fails for anonymous classes -- please
    # submit a patch if you have a workaround.
    def subclasses_of(*superclasses) #:nodoc:
      subclasses = []

      superclasses.each do |sup|
        ObjectSpace.each_object(class << sup; self; end) do |k|
          if k != sup && (k.name.blank? || eval("defined?(::#{k}) && ::#{k}.object_id == k.object_id"))
            subclasses << k
          end
        end
      end

      subclasses
    end
  rescue RuntimeError
    # JRuby and any implementations which cannot handle the objectspace traversal
    # above fall back to this implementation
    def subclasses_of(*superclasses) #:nodoc:
      subclasses = []

      superclasses.each do |sup|
        ObjectSpace.each_object(Class) do |k|
          if superclasses.any? { |superclass| k < superclass } &&
            (k.name.blank? || eval("defined?(::#{k}) && ::#{k}.object_id == k.object_id"))
            subclasses << k
          end
        end
        subclasses.uniq!
      end
      subclasses
    end
  end
end

class Class
  # Returns an array with the names of the subclasses of +self+ as strings.
  #
  #   Integer.subclasses # => ["Bignum", "Fixnum"]
  def subclasses
    Object.subclasses_of(self).map { |o| o.to_s }
  end
end
