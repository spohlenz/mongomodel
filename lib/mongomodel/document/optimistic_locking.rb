module MongoModel
  module DocumentExtensions
    module OptimisticLocking
      extend ActiveSupport::Concern
      
      module ClassMethods
        def locking_enabled?
          properties.include?(:_lock_version)
        end
        
        def lock_optimistically=(value)
          if value == true
            property :_lock_version, Integer, :default => 0, :internal => true, :protected => true
            before_save :increment_lock_version, :if => :locking_enabled?
          else
            properties.delete(:_lock_version)
          end
        end
      end
      
      def locking_enabled?
        self.class.locking_enabled?
      end
    
    private
      def increment_lock_version
        self._lock_version += 1
      end
      
      def save_to_collection
        if locking_enabled? && _lock_version > 1
          begin
            collection.update({ '_id' => id, '_lock_version' => _lock_version-1 }, to_mongo)
            success = database.get_last_error['updatedExisting']
            
            self._lock_version -= 1 unless success
            
            success
          rescue Mongo::OperationFailure => e
            false
          end
        else
          super
        end
      end
    end
  end
end
