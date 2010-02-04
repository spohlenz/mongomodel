require 'active_support/core_ext/object/blank'

class Boolean < TrueClass; end

class Symbol
  [:lt, :lte, :gt, :gte, :ne, :in, :nin, :mod, :all, :size, :exists].each do |operator|
    define_method(operator) { MongoModel::MongoOperator.new(self, operator) }
  end
  
  define_method(:asc) { MongoModel::MongoOrder::Clause.new(self, :ascending) }
  define_method(:desc) { MongoModel::MongoOrder::Clause.new(self, :descending) }
end

class Class
  # Rubinius
  if defined?(Class.__subclasses__)
    def descendents
      subclasses = []
      __subclasses__.each {|k| subclasses << k; subclasses.concat k.descendents }
      subclasses
    end
  else
    # MRI
    begin
      ObjectSpace.each_object(Class.new) {}

      def descendents
        subclasses = []
        ObjectSpace.each_object(class << self; self; end) do |k|
          subclasses << k unless k == self
        end
        subclasses
      end
    # JRuby
    rescue StandardError
      def descendents
        subclasses = []
        ObjectSpace.each_object(Class) do |k|
          subclasses << k if k < self
        end
        subclasses.uniq!
        subclasses
      end
    end
  end
  
  def reachable?
    eval("defined?(::#{self}) && ::#{self}.equal?(self)")
  end
  
  def subclasses
    Object.subclasses_of(self).map { |o| o.to_s }
  end
end

class Object
    def remove_subclasses_of(*superclasses) #:nodoc:
      Class.remove_class(*subclasses_of(*superclasses))
    end
  
  # Exclude this class unless it's a subclass of our supers and is defined.
  # We check defined? in case we find a removed class that has yet to be
  # garbage collected. This also fails for anonymous classes -- please
  # submit a patch if you have a workaround.
  def subclasses_of(*superclasses) #:nodoc:
    subclasses = []
    superclasses.each do |klass|
      subclasses.concat klass.descendents.select {|k| k.name.blank? || k.reachable?}
    end
    subclasses
  end
end
