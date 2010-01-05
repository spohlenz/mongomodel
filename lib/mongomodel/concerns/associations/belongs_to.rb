module MongoModel
  module Associations
    class BelongsTo < Base::Definition
      def foreign_key
        :"#{name}_id"
      end
      
      def type_key
        :"#{name}_type"
      end
      
      properties do |association|
        property association.foreign_key, String, :internal => true
        property association.type_key, String, :internal => true if association.polymorphic?
      end
      
      methods do |association|
        define_method(association.name) do |*args|
          force_reload = args.first || false
          
          associations[association.name].proxy.reset if force_reload
          associations[association.name].proxy
        end
        
        define_method("#{association.name}=") { |obj| associations[association.name].replace(obj) }
        
        unless association.polymorphic?
          define_method("build_#{association.name}") do |*args|
            associations[association.name].replace(association.klass.new(*args))
          end
        
          define_method("create_#{association.name}") do |*args|
            associations[association.name].replace(association.klass.create(*args))
          end
        end
      end
      
      class Association < Base::Association
        delegate :foreign_key, :type_key, :to => :definition
        
        def target_id
          instance[foreign_key]
        end
        
        def target_class
          if polymorphic?
            instance[type_key].constantize rescue nil
          else
            klass
          end
        end
        
        def replace(obj)
          ensure_class(obj) unless polymorphic?
          
          instance[foreign_key] = obj.id
          instance[type_key] = obj.class if polymorphic?
          
          super
        end
        
        def find_target
          target_class.find(target_id) unless target_id.nil? || target_class.nil?
        end
      end
    end
  end
end
