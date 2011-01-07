module MongoModel
  module DocumentExtensions
    module Updating
      extend ActiveSupport::Concern
      
      module ClassMethods
        def increase!(values)
          selector = MongoOptions.new(self, scoped.finder_options).selector
          collection.update(selector, { "$inc" => values.stringify_keys! }, :multi => true)
        end
      end
      
      module InstanceMethods
        def increase!(values)
          self.class.where(:id => id).increase!(values)
        end
      end
      
    end
  end
end