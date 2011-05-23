module MongoModel
  module DocumentExtensions
    module Observing
      extend ActiveSupport::Concern
      include ActiveModel::Observing

      included do
        # reject the around_* callbacks
        MongoModel::Callbacks::CALLBACKS.reject{|c|c.to_s=~/^around_/}.each do |callback|
          next unless respond_to?(callback)
          callback_method = :"notify_observers_#{callback}"
          unless respond_to?(callback_method)
            define_method(callback_method) do |&block|
              notify_observers(callback, &block)
            end
            private callback_method
          end
          send(callback, callback_method)
        end
      end
    end
  end
end
