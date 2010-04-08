module MongoModel
  module DocumentExtensions
    module Persistence
      extend ActiveSupport::Concern
      
      included do
        undef_method :id if method_defined?(:id)
        property :id, String, :as => '_id', :default => lambda { |doc| doc.generate_id }
        
        class_inheritable_writer :collection_name
      end
      
      def save
        create_or_update
      end

      def save!
        create_or_update || raise(DocumentNotSaved)
      end
      
      def delete
        self.class.delete(id)
        set_destroyed(true)
        freeze
      end
      
      def destroy
        delete
      end
      
      # Updates all the attributes from the passed-in Hash and saves the document.
      # If the object is invalid, the saving will fail and false will be returned.
      def update_attributes(attributes)
        self.attributes = attributes
        save
      end
      
      # Updates a single attribute and saves the document without going through the normal validation procedure.
      # This is especially useful for boolean flags on existing documents.
      def update_attribute(name, value)
        send("#{name}=", value)
        save(false)
      end
      
      def collection
        self.class.collection
      end
      
      def database
        self.class.database
      end
      
      def generate_id
        ::BSON::ObjectID.new.to_s
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

        def delete(id_or_conditions)
          collection.remove(MongoOptions.new(self, :conditions => id_to_conditions(id_or_conditions)).selector)
        end

        def destroy(id_or_conditions)
          find(:all, :conditions => id_to_conditions(id_or_conditions)).each { |instance| instance.destroy }
        end
        
        def from_mongo(document)
          instance = super
          instance.send(:instantiate, document)
          instance
        end
        
        def collection_name
          if superclass.abstract_class?
            read_inheritable_attribute(:collection_name) || name.tableize.gsub(/\//, '.')
          else
            superclass.collection_name
          end
        end

        def collection
          @_collection ||= database.collection(collection_name)
        end
        
        def database
          MongoModel.database
        end
        
        def save_safely?
          @save_safely
        end
        
        def save_safely=(val)
          @save_safely = val
        end
        
      private
        def id_to_conditions(id_or_conditions)
          case id_or_conditions
          when String
            { :id => id_or_conditions }
          when Array
            { :id.in => id_or_conditions }
          else
            id_or_conditions
          end
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
        collection.save(to_mongo, :safe => self.class.save_safely?)
        set_new_record(false)
        true
      rescue Mongo::OperationFailure => e
        false
      end

      def instantiate(document)
        attributes.from_mongo!(document)
        set_new_record(false)
      end
    end
  end
end
