module MongoModel
  module Associations
    class BelongsTo < Base::Definition
      def foreign_key
        :"#{name}_id"
      end
      
      properties do |association|
        property association.foreign_key, String, :internal => true
      end
      
      methods do |association|
        define_method(association.name) { associations[association.name].proxy }
        define_method("#{association.name}=") { |obj| associations[association.name].replace(obj) }
        
        define_method("build_#{association.name}") do |*args|
          associations[association.name].replace(association.klass.new(*args))
        end
        
        define_method("create_#{association.name}") do |*args|
          associations[association.name].replace(association.klass.create(*args))
        end
      end
      
      class Association < Base::Association
        delegate :foreign_key, :to => :definition
        
        def target_id
          instance[foreign_key]
        end
        
        def replace(obj)
          if obj.is_a?(klass)
            instance[foreign_key] = obj.id
            super
          else
            raise AssociationTypeMismatch, "expected instance of #{klass} but got #{obj.class}"
          end
        end
        
        def find_target
          klass.find(target_id) unless target_id.nil?
        end
      end
    end
  end
end
