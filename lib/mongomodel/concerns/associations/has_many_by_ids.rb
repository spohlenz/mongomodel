module MongoModel
  module Associations
    class HasManyByIds < Base::Definition
      def property_name
        :"#{singular_name}_ids"
      end
      
      def define!
        super
        define_dependency_callbacks!
        self
      end
      
      def define_dependency_callbacks!
        association = self
        
        if options[:dependent] == :destroy
          owner.before_destroy do
            send(association.name).each { |child| child.destroy }
          end
        elsif options[:dependent] == :delete
          owner.before_destroy do
            send(association.name).delete_all
          end
        end
      end
      
      properties do |association|
        property association.property_name, Collection[MongoModel::Reference], :internal => true, :default => []
      end
      
      methods do |association|
        define_method(association.name) { associations[association.name].proxy }
        define_method("#{association.name}=") { |obj| associations[association.name].replace(obj) }
      end
      
      class Association < Base::Association
        delegate :property_name, :to => :definition
        
        def ids
          instance[property_name]
        end
        
        def replace(array)
          ensure_class(array)
          
          instance[property_name] = array.map { |i| i.id }
          super
        end
        
        def find_target
          ids.any? ? Array.wrap(definition.scope.find(ids - new_document_ids)) + new_documents : []
        end
        
        def build(*args, &block)
          doc = scoped.new(*args, &block)
          new_documents << doc
          doc
        end
        
        def create(*args, &block)
          scoped.create(*args, &block)
        end
        
        def scoped
          definition.scope.where(:id.in => ids)
        end
        
      protected
        def new_documents
          @new_documents ||= []
        end
        
        def new_document_ids
          new_documents.map { |doc| doc.id }
        end
      
        def ensure_class(array)
          array.is_a?(Array) ? array.each { |i| super(i) } : super
        end
      end
      
      class Proxy < Base::Proxy
        # Pass these methods to the association class rather than the Array target
        OVERRIDE_METHODS = [ :find ]
        
        delegate :ensure_class, :to => :association
        
        def build(*args, &block)
          doc = association.build(*args, &block)
          self << doc
          doc
        end
        
        def create(*args, &block)
          doc = association.create(*args, &block)
          self << doc
          doc
        end
        
        def []=(index, doc)
          ensure_class(doc)
          super if loaded?
          ids[index] = doc.id
          self
        end
        
        def <<(doc)
          ensure_class(doc)
          super if loaded?
          ids << doc.id
          self
        end
        
        def concat(documents)
          ensure_class(documents)
          super if loaded?
          ids.concat(documents.map { |doc| doc.id })
          self
        end
        
        def insert(index, doc)
          ensure_class(doc)
          super if loaded?
          ids.insert(index, doc.id)
          self
        end
        
        def replace(documents)
          ensure_class(documents)
          super if loaded?
          ids.replace(documents.map { |doc| doc.id })
          self
        end
        
        def push(*documents)
          ensure_class(documents)
          super if loaded?
          ids.push(*documents.map { |doc| doc.id })
          self
        end
        
        def unshift(*documents)
          ensure_class(documents)
          super if loaded?
          ids.unshift(*documents.map { |doc| doc.id })
          self
        end
        
        def clear
          super if loaded?
          ids.clear
          self
        end
        
        def delete(doc)
          super if loaded?
          ids.delete(doc.id)
          self
        end
        
        def delete_at(index)
          super if loaded?
          ids.delete_at(index)
          self
        end
        
        def delete_if(&block)
          super
          ids.replace(map { |doc| doc.id })
          self
        end
        
        def ids
          association.ids
        end
      
      private
        def method_missing(method_id, *args, &block)
          if target.respond_to?(method_id) && !OVERRIDE_METHODS.include?(method_id.to_sym)
            super(method_id, *args, &block)
          else
            association.scoped.send(method_id, *args, &block)
          end
        end
      end
    end
  end
end
