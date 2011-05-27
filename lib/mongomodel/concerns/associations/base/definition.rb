module MongoModel
  module Associations
    module Base
      class Definition
        attr_reader :owner, :name, :options

        def initialize(owner, name, options={})
          @owner, @name, @options = owner, name, options
        end

        def for(instance)
          association_class.new(self, instance)
        end

        def define!
          owner.instance_exec(self, &self.class.properties) if self.class.properties
          owner.instance_exec(self, &self.class.methods) if self.class.methods

          self
        end

        def klass
          case options[:class]
          when Class
            options[:class]
          when String
            options[:class].constantize
          else
            name.to_s.classify.constantize
          end
        end
        
        def singular_name
          name.to_s.singularize
        end

        def polymorphic?
          options[:polymorphic]
        end
        
        def scope
          klass.scoped.apply_finder_options(scope_options)
        end
        
        def scope_options
          options.slice(:conditions, :select, :offset, :limit, :order)
        end

        def self.properties
          @properties = Proc.new if block_given?
          @properties
        end

        def self.methods(&block)
          @methods = Proc.new if block_given?
          @methods
        end

      private
        def association_class
          self.class::Association rescue Base::Association
        end
      end
    end
  end
end
