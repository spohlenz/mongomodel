module MongoModel
  module DocumentExtensions
    module Callbacks
      extend ActiveSupport::Concern

      def instantiate(*) #:nodoc:
        super
        run_callbacks_with_embedded(:find)
      end
      private :instantiate

      def create_or_update #:nodoc:
        run_callbacks_with_embedded(:save) do
          super
        end
      end
      private :create_or_update

      def create #:nodoc:
        run_callbacks_with_embedded(:create) do
          super
        end
      end
      private :create

      def update(*) #:nodoc:
        run_callbacks_with_embedded(:update) do
          super
        end
      end
      private :update

      def destroy #:nodoc:
        run_callbacks_with_embedded(:destroy) do
          super
        end
      end
    end
  end
end
