module MongoModel
  module DocumentExtensions
    module Persistence
      extend ActiveSupport::Concern
      
      included do
        undef_method :id if method_defined?(:id)
        property :id, String, :as => '_id', :default => lambda { ::Mongo::ObjectID.new.to_s }
        
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
      
      def collection
        self.class.collection
      end
      
      def database
        self.class.database
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
          instance = new
          instance.send(:instantiate, document)
          instance
        end
        
        def collection_name
          read_inheritable_attribute(:collection_name) || name.tableize.gsub(/\//, '.')
        end

        def collection
          @_collection ||= database.collection(collection_name)
        end
        
        def database
          MongoModel.database
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
        collection.save(to_mongo)
        set_new_record(false)
        true
      end

      def instantiate(document)
        attributes.from_mongo!(document)
        set_new_record(false)
      end
    end
  end
end
