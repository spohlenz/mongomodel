module MongoModel
  module Associations
    class PolymorphicBelongsTo < Base::Definition
      def foreign_key
        :"#{name}_id"
      end
      
      def type_key
        :"#{name}_type"
      end
      
      properties do |association|
        property association.foreign_key, String, :internal => true
        property association.type_key, String, :internal => true
      end
      
      methods do |association|
        define_method(association.name) { associations[association.name].proxy }
        define_method("#{association.name}=") { |obj| associations[association.name].replace(obj) }
      end
      
      class Association < Base::Association
        delegate :foreign_key, :type_key, :to => :definition
        
        def target_id
          instance[foreign_key]
        end
        
        def target_class
          instance[type_key].constantize rescue nil
        end
        
        def replace(obj)
          instance[foreign_key] = obj.id
          instance[type_key] = obj.class
          super
        end
        
        def find_target
          target_class.find(target_id) unless target_id.nil? || target_class.nil?
        end
      end
    end
  end
end
