module MongoModel
  class Observer < ActiveModel::Observer
    protected

    def observed_classes
      super.map(&:type_selector).flatten.map(&:constantize)
    end

  end
end
