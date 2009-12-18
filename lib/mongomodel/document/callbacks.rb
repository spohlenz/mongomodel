module MongoModel
  module DocumentExtensions
    module Callbacks
      extend ActiveSupport::Concern
      
      included do
        [:instantiate, :create_or_update, :create, :update, :destroy].each do |method|
          alias_method_chain method, :callbacks
        end
      end
      
      def instantiate_with_callbacks(*args) #:nodoc:
        instantiate_without_callbacks(*args)
        run_callbacks_with_embedded(:find)
      end
      private :instantiate_with_callbacks

      def create_or_update_with_callbacks #:nodoc:
        run_callbacks_with_embedded(:save) do
          create_or_update_without_callbacks
        end
      end
      private :create_or_update_with_callbacks

      def create_with_callbacks #:nodoc:
        run_callbacks_with_embedded(:create) do
          create_without_callbacks
        end
      end
      private :create_with_callbacks

      def update_with_callbacks(*args) #:nodoc:
        run_callbacks_with_embedded(:update) do
          update_without_callbacks(*args)
        end
      end
      private :update_with_callbacks

      def destroy_with_callbacks #:nodoc:
        run_callbacks_with_embedded(:destroy) do
          destroy_without_callbacks
        end
      end
    end
  end
end
