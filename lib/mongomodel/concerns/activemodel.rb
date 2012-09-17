module MongoModel
  module ActiveModelCompatibility
    extend ActiveSupport::Concern
    
    include ActiveModel::Conversion
    
    def persisted?
      !new_record?
    end
    
    def to_key
      persisted? ? super : nil
    end
    
    module ClassMethods
      include ActiveModel::Naming
    end
  end
end
