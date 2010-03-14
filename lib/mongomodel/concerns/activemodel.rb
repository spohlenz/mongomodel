module MongoModel
  module ActiveModelCompatibility
    extend ActiveSupport::Concern
    
    include ActiveModel::Conversion
    
    def persisted?
      !new_record?
    end
    
    module ClassMethods
      include ActiveModel::Naming
    end
  end
end
