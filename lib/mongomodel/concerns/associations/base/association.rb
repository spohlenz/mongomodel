require 'active_support/core_ext/module/introspection'

module MongoModel
  module Associations
    module Base
      class Association
        attr_reader :definition, :instance
        delegate :name, :klass, :polymorphic?, :to => :definition
        
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
        
        def ensure_class(value)
          raise AssociationTypeMismatch, "expected instance of #{klass} but got #{value.class}" unless value.is_a?(klass)
        end
      
      protected
        def proxy_class
          self.class.parent::Proxy rescue Base::Proxy
        end
      end
    end
  end
end
