require "active_model/forbidden_attributes_protection"

module MongoModel
  module AttributeMethods
    module Forbidden
      extend ActiveSupport::Concern
      
      def assign_attributes(attrs, options={})
        if attrs.respond_to?(:permitted?) && !attrs.permitted?
          raise ActiveModel::ForbiddenAttributesError
        else
          super
        end
      end
    end
  end
end
