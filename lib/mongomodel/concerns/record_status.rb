require 'active_support/core_ext/module/aliasing'

module MongoModel
  module RecordStatus
    extend ActiveSupport::Concern

    def new_record?
      @_new_record
    end

    def destroyed?
      @_destroyed
    end

    def initialize(*)
      set_new_record(true)
      set_destroyed(false)

      super
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
