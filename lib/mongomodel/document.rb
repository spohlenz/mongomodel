require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/string/inflections'

module MongoModel
  class Document < EmbeddedDocument
    def ==(other)
      self.class == other.class && id == other.id
    end
    
    include DocumentExtensions::Persistence
    include DocumentExtensions::OptimisticLocking
    include DocumentExtensions::CollectionModifiers
    
    extend  DocumentExtensions::DynamicFinders
    include DocumentExtensions::Indexes
    
    include DocumentExtensions::Scopes
    include DocumentExtensions::Validations
    include DocumentExtensions::Callbacks
    include DocumentExtensions::Observing

    self.abstract_class = true
    
    class_attribute :per_page
    self.per_page = 20
  end
end

ActiveSupport.run_load_hooks(:mongo_model, MongoModel::Document)