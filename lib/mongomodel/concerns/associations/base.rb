module MongoModel
  module Associations
    module Base
      class Definition
        attr_reader :name, :options

        def initialize(name, options={})
          @name, @options = name, options
        end

        def for(instance)
          association_class.new(self, instance)
        end

        def define(model)
          model.instance_exec(self, &self.class.properties) if self.class.properties
          model.instance_exec(self, &self.class.methods) if self.class.methods

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
        
        def polymorphic?
          options[:polymorphic]
        end

        def self.properties(&block)
          block_given? ? write_inheritable_attribute(:properties, block) : read_inheritable_attribute(:properties)
        end

        def self.methods(&block)
          block_given? ? write_inheritable_attribute(:methods, block) : read_inheritable_attribute(:methods)
        end
        
      private
        def association_class
          self.class::Association rescue Base::Association
        end
      end
      
      class Association
        attr_reader :definition, :instance
        delegate :klass, :to => :definition
        
        def initialize(definition, instance)
          @definition, @instance = definition, instance
        end
        
        def proxy
          @proxy ||= proxy_class.new(self)
        end
        
        def replace(obj)
          proxy.target = obj
          proxy
        end
      
      private
        def proxy_class
          self.class.parent::Proxy rescue Base::Proxy
        end
      end
      
      class Proxy
        alias_method :proxy_respond_to?, :respond_to?
        alias_method :proxy_extend, :extend

        instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$|proxy_|^object_id$)/ }
  
        attr_reader :association
  
        def initialize(association)
          @association = association
        end
        
        def target=(new_target)
          @target = new_target
          loaded!
          @target
        end
  
        def target
          load_target
          @target
        end
  
        def loaded?
          @loaded
        end
  
        def loaded!
          @loaded = true
        end
  
        def reset
          @loaded = false
          @target = nil
        end
  
        def respond_to?(*args)
          proxy_respond_to?(*args) || target.respond_to?(*args)
        end

      private
        def method_missing(*args, &block)
          target.send(*args, &block)
        end
  
        def load_target
          @target = @association.find_target unless loaded?
          loaded!
        rescue MongoModel::DocumentNotFound
          reset
        end
      end
    end
  end
end
