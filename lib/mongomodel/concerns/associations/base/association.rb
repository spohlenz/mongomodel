module MongoModel
  module Associations
    module Base
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
    end
  end
end
