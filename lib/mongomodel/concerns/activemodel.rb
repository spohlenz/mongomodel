module MongoModel
  module ActiveModelCompatibility
    extend ActiveSupport::Concern
    
    include ActiveModel::Conversion
    
    module ClassMethods
      include ActiveModel::Naming
    end
  end
end
