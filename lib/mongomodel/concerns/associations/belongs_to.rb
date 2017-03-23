module MongoModel
  module Associations
    class BelongsTo < Base::Definition
      def foreign_key
        @foreign_key ||= options[:foreign_key] || :"#{name}_id"
      end
      
      def type_key
        @type_key ||= options[:type_key] || :"#{name}_type"
      end
      
      def collection?
        false
      end
      
      properties do |association|
        property association.foreign_key, MongoModel::Reference, :internal => true
        property association.type_key, String, :internal => true if association.polymorphic?
      end
      
      methods do |association|
        define_method(association.name) do |*args|
          force_reload = args.first unless args.empty?
          
          proxy = associations[association.name].proxy
          
          proxy.reset if force_reload
          proxy.target.nil? ? nil : proxy
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
          ensure_class(obj) if obj && !polymorphic?
          
          instance[foreign_key] = obj ? obj.id : nil
          instance[type_key] = obj ? obj.class : nil if polymorphic?
          
          super
        end
        
        def find_target
          target_class.find(target_id) if target_id && target_class
        end
      
      protected
        def proxy_class
          Base::Proxy
        end
      end
    end
  end
end
