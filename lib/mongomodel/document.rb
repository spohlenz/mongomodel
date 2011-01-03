require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/string/inflections'

module MongoModel
  class Document < EmbeddedDocument
    include DocumentExtensions::Persistence
    include DocumentExtensions::OptimisticLocking
    
    extend  DocumentExtensions::DynamicFinders
    include DocumentExtensions::Indexes
    
    include DocumentExtensions::Scopes
    include DocumentExtensions::Validations
    include DocumentExtensions::Callbacks
    
    self.abstract_class = true
    
    cattr_accessor :per_page
    self.per_page = 20
  end
end
