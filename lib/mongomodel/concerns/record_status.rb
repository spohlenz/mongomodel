require 'active_support/core_ext/module/aliasing'

module MongoModel
  module RecordStatus
    extend ActiveSupport::Concern
    
    included do
      alias_method_chain :initialize, :record_status
    end
    
    def new_record?
      @_new_record
    end
    
    def destroyed?
      @_destroyed
    end
    
    def initialize_with_record_status(*args, &block)
      set_new_record(true)
      set_destroyed(false)
      
      initialize_without_record_status(*args, &block)
    end
    
  protected
    def set_new_record(value)
      set_record_status(:new_record, value)
    end
    
    def set_destroyed(value)
      set_record_status(:destroyed, value)
    end
  
  private
    def set_record_status(type, value)
      instance_variable_set("@_#{type}", value)
      embedded_documents.each { |doc| doc.send(:set_record_status, type, value) }
      value
    end
  end
end
