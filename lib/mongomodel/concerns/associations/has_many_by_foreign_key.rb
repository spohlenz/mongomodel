module MongoModel
  module Associations
    class HasManyByForeignKey < Base::Definition
      def foreign_key
        @foreign_key ||= options[:foreign_key] || :"#{inverse_of}_id"
      end

      def inverse_of
        @inverse_of ||= options[:inverse_of] || owner.to_s.demodulize.underscore.singularize.to_sym
      end

      def define!
        raise "has_many :by => :foreign_key is only valid on Document" unless owner.ancestors.include?(Document)

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

      methods do |association|
        define_method(association.name) { associations[association.name].proxy }
        define_method("#{association.name}=") { |obj| associations[association.name].replace(obj) }
      end

      class Association < Base::Association
        delegate :foreign_key, :inverse_of, :to => :definition

        def find_target
          scoped.each { |doc|
            doc.send("#{inverse_of}=", instance) if doc.respond_to?("#{inverse_of}=")
          } + new_documents
        end

        def build(*args, &block)
          doc = scoped.new(*args, &block)
          new_documents << doc
          doc
        end

        def create(*args)
          scoped.create(*args) do |doc|
            set_inverse_association(doc)
            yield doc if block_given?
          end
        end

        def create!(*args)
          scoped.create!(*args) do |doc|
            set_inverse_association(doc)
            yield doc if block_given?
          end
        end

        def replace(array)
          ensure_class(array)
          array.each { |doc| assign(doc) }
          super
        end

        def assign(doc)
          set_inverse_association(doc)
          doc.save(false) unless doc.new_record?
        end

        def unset(doc)
          if doc.respond_to?("#{inverse_of}=")
            doc.send("#{inverse_of}=", nil) if doc.send(inverse_of) == instance
          else
            doc[foreign_key] = nil if doc[foreign_key] == instance.id
          end

          doc.save(false) unless doc.new_record?
        end

        def scoped
          definition.scope.where(foreign_key => instance.id).on_load { |doc| set_inverse_association(doc) }
        end

        def ensure_class(array)
          array.is_a?(Array) ? array.each { |i| super(i) } : super
        end

      protected
        def new_documents
          @new_documents ||= []
        end

        def set_inverse_association(doc)
          if doc.respond_to?("#{inverse_of}=")
            doc.send("#{inverse_of}=", instance)
          else
            doc[foreign_key] = instance.id
          end
        end

        def proxy_class
          Proxy
        end
      end

      class Proxy < Base::Proxy
        # Pass these methods to the scope rather than the Array target
        OVERRIDE_METHODS = [ :find, :first, :last, :count, :paginate ]

        delegate :ensure_class, :to => :association

        def build(*args)
          association.build(*args) do |doc|
            self << doc
            yield doc if block_given?
          end
        end

        def create(*args)
          association.create(*args) do |doc|
            self << doc
            yield doc if block_given?
          end
        end

        def create!(*args)
          association.create!(*args) do |doc|
            self << doc
            yield doc if block_given?
          end
        end

        def []=(index, doc)
          ensure_class(doc)
          association.unset(target[index]) if target[index]
          association.assign(doc)
          super if loaded?
          self
        end

        def <<(*documents)
          documents.flatten!
          ensure_class(documents)
          documents.each { |doc| association.assign(doc) }
          super if loaded?
          self
        end

        alias_method :push, :<<
        alias_method :concat, :<<

        def insert(index, doc)
          ensure_class(doc)
          association.assign(doc)
          super if loaded?
          self
        end

        def unshift(*documents)
          ensure_class(documents)
          documents.each { |doc| association.assign(doc) }
          super if loaded?
          self
        end

        def delete(doc)
          association.unset(doc)
          super
          self
        end

        def delete_at(index)
          association.unset(target[index])
          super
          self
        end

        def ids
          target.map { |doc| doc.id }
        end

        def select(*args, &block)
          if args.empty?
            target.select(&block)
          else
            association.scoped.send(:select, *args)
          end
        end

      private
        def method_missing(method, *args, &block)
          if Array.method_defined?(method) && !OVERRIDE_METHODS.include?(method)
            target.send(method, *args, &block)
          elsif association.scoped.respond_to?(method)
            association.scoped.send(method, *args, &block)
          else
            super(method, *args, &block)
          end
        end
      end
    end
  end
end
