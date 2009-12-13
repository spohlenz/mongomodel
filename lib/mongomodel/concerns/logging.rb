module MongoModel
  module Logging
    extend ActiveSupport::Concern
    
    module ClassMethods
      def logger
        MongoModel.logger
      end
    end
    
    def logger
      self.class.logger
    end
  end
end
