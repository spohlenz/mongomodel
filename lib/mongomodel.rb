require 'active_support'
require 'active_model'

require 'mongo'

require 'mongomodel/support/core_extensions'
require 'mongomodel/support/exceptions'

module MongoModel  
  autoload :Document,         'mongomodel/document'
  autoload :EmbeddedDocument, 'mongomodel/embedded_document'
  
  autoload :Properties,       'mongomodel/concerns/properties'
  autoload :Attributes,       'mongomodel/concerns/attributes'
  autoload :AttributeMethods, 'mongomodel/concerns/attribute_methods'
  autoload :Validations,      'mongomodel/concerns/validations'
  autoload :Callbacks,        'mongomodel/concerns/callbacks'
  autoload :Timestamps,       'mongomodel/concerns/timestamps'
  autoload :PrettyInspect,    'mongomodel/concerns/pretty_inspect'
  autoload :NewRecord,        'mongomodel/concerns/new_record'
  
  autoload :MongoOptions,     'mongomodel/support/mongo_options'
  autoload :MongoOperator,    'mongomodel/support/mongo_options'
  autoload :Types,            'mongomodel/support/types'
  
  module AttributeMethods
    autoload :Read,           'mongomodel/concerns/attribute_methods/read'
    autoload :Write,          'mongomodel/concerns/attribute_methods/write'
    autoload :Query,          'mongomodel/concerns/attribute_methods/query'
    autoload :BeforeTypeCast, 'mongomodel/concerns/attribute_methods/before_type_cast'
    autoload :Protected,      'mongomodel/concerns/attribute_methods/protected'
    autoload :Dirty,          'mongomodel/concerns/attribute_methods/dirty'
  end
  
  module Attributes
    autoload :Store,          'mongomodel/attributes/store'
    autoload :Typecasting,    'mongomodel/attributes/typecasting'
    autoload :Mongo,          'mongomodel/attributes/mongo'
  end
  
  module DocumentExtensions
    autoload :Persistence,    'mongomodel/document/persistence'
    autoload :Finders,        'mongomodel/document/finders'
    autoload :Indexes,        'mongomodel/document/indexes'
    autoload :Scopes,         'mongomodel/document/scopes'
    autoload :Scope,          'mongomodel/document/scopes'
    autoload :Validations,    'mongomodel/document/validations'
    autoload :Callbacks,      'mongomodel/document/callbacks'
  end
  
  def self.database
    @database ||= Mongo::Connection.new.db("mydb")
  end
end

I18n.load_path << File.dirname(__FILE__) + '/mongomodel/locale/en.yml'
