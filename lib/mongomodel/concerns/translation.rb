module MongoModel
  module Translation
    extend ActiveSupport::Concern

    module ClassMethods
      include ActiveModel::Translation

      # Set the i18n scope to overwrite ActiveModel.
      def i18n_scope #:nodoc:
        :mongomodel
      end
    end
  end
end
