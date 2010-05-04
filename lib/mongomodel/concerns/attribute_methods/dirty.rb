module MongoModel
  module AttributeMethods
    module Dirty
      extend ActiveSupport::Concern
      
      include ActiveModel::Dirty
      
      included do
        after_save { changed_attributes.clear }
      end
      
      # Returns the attributes as they were before any changes were made to the document.
      def original_attributes
        attributes.merge(changed_attributes)
      end
    
    protected
      def changed_attributes
        attributes.changed
      end
    end
  end
end
