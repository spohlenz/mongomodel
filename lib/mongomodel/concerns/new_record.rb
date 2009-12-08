require 'active_support/core_ext/module/aliasing'

module MongoModel
  module NewRecord
    extend ActiveSupport::Concern
    
    included do
      alias_method_chain :initialize, :new_record
    end
    
    def new_record?
      @_new_record
    end
    
    def initialize_with_new_record(*args, &block)
      set_new_record(true)
      initialize_without_new_record(*args, &block)
    end
    
  private
    def set_new_record(value)
      @_new_record = value
      embedded_documents.each { |doc| doc.send(:set_new_record, value) }
      value
    end
  end
end
