module MongoModel
  module DocumentExtensions
    module Persistence
      extend ActiveSupport::Concern
      
      included do
        undef_method :id if method_defined?(:id)
        property :id, MongoModel::Reference, :as => '_id', :default => lambda { |doc| doc.generate_id }
      end
      
      # Reload the document from the database. If the document
      # hasn't been saved, this method will raise an error.
      def reload
        reloaded = self.class.unscoped.find(id)
        
        attributes.clear
        attributes.load!(reloaded.attributes.to_mongo)
        
        associations.values.each do |association|
          association.proxy.reset
        end
        
        self
      end

      # Save the document to the database. Returns +true+ on success.
      def save(*)
        create_or_update
      end

      # Save the document to the database. Raises a DocumentNotSaved exception if it fails.
      def save!(*)
        create_or_update || raise(DocumentNotSaved)
      end
      
      def delete
        self.class.unscoped.delete(id)
        set_destroyed(true)
        freeze
      end

      # Remove the document from the database.
      def destroy
        delete
      end
      
      # Updates all the attributes from the passed-in Hash and saves the document.
      # If the object is invalid, the saving will fail and false will be returned.
      #
      # When updating model attributes, mass-assignment security protection is respected.
      # If no +:as+ option is supplied then the +:default+ role will be used.
      # If you want to bypass the protection given by +attr_protected+ and
      # +attr_accessible+ then you can do so using the +:without_protection+ option.
      def update_attributes(attributes, options={})
        self.assign_attributes(attributes, options)
        save
      end
      
      # Updates its receiver just like +update_attributes+ but calls <tt>save!</tt> instead
      # of +save+, so an exception is raised if the docuemnt is invalid.
      def update_attributes!(attributes, options={})
        self.assign_attributes(attributes, options)
        save!
      end
      
      # Updates a single attribute and saves the document without going through the normal validation procedure.
      # This is especially useful for boolean flags on existing documents.
      def update_attribute(name, value)
        send("#{name}=", value)
        save(:validate => false)
      end
      
      def collection
        self.class.collection
      end
      
      def database
        self.class.database
      end
      
      # Generate a new BSON::ObjectId for the record.
      # Override in subclasses for custom ID generation.
      def generate_id
        ::BSON::ObjectId.new.to_s
      end
      
      module ClassMethods
        def create(attributes={}, &block)
          if attributes.is_a?(Array)
            attributes.map { |attrs| create(attrs, &block) }
          else
            instance = new(attributes, &block)
            instance.save
            instance
          end
        end

        def from_mongo(hash)
          instance = super
          instance.send(:instantiate) if instance
          instance
        end
        
        def collection_name
          if superclass.abstract_class?
            @_collection_name || name.tableize.gsub(/\//, '.')
          else
            superclass.collection_name
          end
        end
        
        def collection_name=(name)
          @_collection_name = name
        end
        
        def use_type_selector?
          !superclass.abstract_class?
        end
        
        def type_selector
          [self.to_s] + descendants.map { |m| m.to_s }
        end

        def collection
          @_collection ||= InstrumentedCollection.new(database.collection(collection_name))
        end
        
        def database
          MongoModel.database
        end
        
        def save_safely?
          @_save_safely
        end
        
        def save_safely=(val)
          @_save_safely = val
        end
      end
    
    private
      def create_or_update
        result = new_record? ? create : update
        result != false
      end

      def create
        save_to_collection
      end

      def update
        save_to_collection
      end
      
      def save_to_collection
        collection.save(to_mongo, :w => self.class.save_safely? ? 1 : 0)
        set_new_record(false)
        true
      rescue Mongo::OperationFailure => e
        false
      end

      def instantiate
        set_new_record(false)
      end
    end
  end
end
