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
        define_method(association.name) { associations[association.name].proxy }
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
        delegate :foreign_key, :type_key, :polymorphic?, :to => :definition
        
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
          if polymorphic? || obj.is_a?(klass)
            instance[foreign_key] = obj.id
            instance[type_key] = obj.class if polymorphic?
            super
          else
            raise AssociationTypeMismatch, "expected instance of #{klass} but got #{obj.class}"
          end
        end
        
        def find_target
          target_class.find(target_id) unless target_id.nil? || target_class.nil?
        end
      end
    end
  end
end
