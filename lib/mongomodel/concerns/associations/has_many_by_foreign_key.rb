module MongoModel
  module Associations
    class HasManyByForeignKey < Base::Definition
      def foreign_key
        :"#{inverse_of}_id"
      end
      
      def inverse_of
        owner.to_s.downcase.singularize
      end
      
      def define!
        raise "has_many :by => :foreign_key is only valid on Document" unless owner.ancestors.include?(Document)
        super
      end
      
      methods do |association|
        define_method(association.name) { associations[association.name].proxy }
        define_method("#{association.name}=") { |obj| associations[association.name].replace(obj) }
      end
      
      class Association < Base::Association
        delegate :foreign_key, :inverse_of, :to => :definition
        
        def find_target
          klass.find(:all, :conditions => { foreign_key => instance.id }) + new_documents
        end
        
        def build(*args, &block)
          doc = klass.new(*args, &block)
          new_documents << doc
          doc
        end
        
        def create(*args, &block)
          klass.create(*args, &block)
        end
        
        def replace(array)
          ensure_class(array)
          array.each { |doc| assign(doc) }
          super
        end
        
        def assign(doc)
          if doc.respond_to?("#{inverse_of}=")
            doc.send("#{inverse_of}=", instance)
          else
            doc[foreign_key] = instance.id
          end
          
          doc.save(false) unless doc.new_record?
        end
        
        def send_to_klass_with_scope(*args, &block)
          fk = foreign_key
          id = instance.id
          
          klass.instance_eval do
            with_scope(:find => { :conditions => { fk => id } }) do
              send(*args, &block)
            end
          end
        end
      
      protected
        def new_documents
          @new_documents ||= []
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
          association.assign(doc)
          super if loaded?
          self
        end
        
        def <<(doc)
          ensure_class(doc)
          association.assign(doc)
          super if loaded?
          self
        end
        
        def concat(documents)
          ensure_class(documents)
          documents.each { |doc| association.assign(doc) }
          super if loaded?
          self
        end
        
        def insert(index, doc)
          ensure_class(doc)
          association.assign(doc)
          super if loaded?
          self
        end
        
        def push(*documents)
          ensure_class(documents)
          documents.each { |doc| association.assign(doc) }
          super if loaded?
          self
        end
        
        def unshift(*documents)
          ensure_class(documents)
          documents.each { |doc| association.assign(doc) }
          super if loaded?
          self
        end
        
        def ids
          target.map { |doc| doc.id }
        end
      
      private
        def method_missing(method_id, *args, &block)
          if target.respond_to?(method_id) && !OVERRIDE_METHODS.include?(method_id.to_sym)
            super(method_id, *args, &block)
          else
            association.send_to_klass_with_scope(method_id, *args, &block)
          end
        end
      end
    end
  end
end
