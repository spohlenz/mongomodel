require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/string/inflections'

module MongoModel
  class Document < EmbeddedDocument
    undef_method :id if method_defined?(:id)
    property :id, String, :as => '_id', :default => lambda { ::Mongo::ObjectID.new.to_s }
    
    def initialize(attrs={})
      @_new_record = true
      super
    end
    
    def new_record?
      @_new_record
    end
    
    def save
      create_or_update
    end
    
    def save!
      create_or_update || raise(DocumentNotSaved)
    end
    
    def self.create(attributes={}, &block)
      if attributes.is_a?(Array)
        attributes.map { |attrs| create(attrs, &block) }
      else
        instance = new(attributes, &block)
        instance.save
        instance
      end
    end
    
    def delete
      self.class.delete(id)
      freeze
    end
    
    def self.delete(id_or_conditions)
      collection.remove(MongoOptions.new(self, :conditions => id_to_conditions(id_or_conditions)).selector)
    end
    
    def destroy
      delete
    end
    
    def self.destroy(id_or_conditions)
      find(:all, :conditions => id_to_conditions(id_or_conditions)).each { |instance| instance.destroy }
    end
    
    def freeze
      attributes.freeze; self
    end
    
    def frozen?
      attributes.frozen?
    end
    
    def self.from_mongo(document)
      instance = new
      instance.send(:instantiate, document)
      instance
    end
    
    class_inheritable_writer :collection_name
    
    def self.collection_name
      read_inheritable_attribute(:collection_name) || name.tableize.gsub(/\//, '.')
    end
    
    def self.collection
      @_collection ||= database.collection(collection_name)
    end
    
    def collection
      self.class.collection
    end
    
    def self.database
      MongoModel.database
    end
    
    def database
      self.class.database
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
      @_new_record = false
      true
    end
    
    def instantiate(document)
      attributes.from_mongo!(document)
      instance_variable_set('@_new_record', false)
    end
    
    def self.id_to_conditions(id_or_conditions)
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
  
  Document.class_eval do
    extend Finders
    
    include Scopes
    
    include Timestamps
    
    include Validations::DocumentExtensions
    include Callbacks::DocumentExtensions
  end
end
