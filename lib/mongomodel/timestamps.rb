module MongoModel
  # MongoModel automatically timestamps create and update operations if the document has properties
  # named created_at/created_on or updated_at/updated_on.
  module Timestamps#:nodoc:
    extend ActiveSupport::Concern
    
    included do
      before_save   :set_save_timestamps
      before_create :set_create_timestamps
    end
    
    module ClassMethods
      # Defines timestamp properties created_at and updated_at.
      # When the document is created or updated, these properties will be respectively updated.
      def timestamps!
        property :created_at, Time
        property :updated_at, Time
      end
    end
    
    def set_save_timestamps
      write_attribute(:updated_at, Time.now) if properties.include?(:updated_at)
      write_attribute(:updated_on, Time.now) if properties.include?(:updated_on)
    end
    
    def set_create_timestamps
      write_attribute(:created_at, Time.now) if properties.include?(:created_at) && !query_attribute(:created_at)
      write_attribute(:created_on, Time.now) if properties.include?(:created_on) && !query_attribute(:created_on)
    end
  end
end
