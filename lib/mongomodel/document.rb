require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/string/inflections'

module MongoModel
  class Document < EmbeddedDocument
    include DocumentExtensions::Persistence
    
    extend  DocumentExtensions::Finders
    extend  DocumentExtensions::DynamicFinders
    include DocumentExtensions::Indexes
    
    include DocumentExtensions::Scopes
    include DocumentExtensions::Validations
    include DocumentExtensions::Callbacks
    
    self.abstract_class = true
  end
end
