module MongoModel
  module Validations
    extend ActiveSupport::Concern
    
    include ActiveModel::Validations
    
    module ClassMethods
      def property(name, *args, &block) #:nodoc:
        property = super(name, *args, &block)
        validates_associated(name) if property.embeddable?
        property
      end
    end
    
    def valid?
      errors.clear
      
      @_on_validate = new_record? ? :create : :update
      run_callbacks(:validate)
      
      errors.empty?
    end
  end
end

Dir[File.dirname(__FILE__) + "/validations/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "mongomodel/concerns/validations/#{filename}"
end
