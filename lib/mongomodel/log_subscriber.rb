module MongoModel
  class LogSubscriber < ActiveSupport::LogSubscriber
    def self.runtime=(value)
      Thread.current["mongomodel_runtime"] = value
    end

    def self.runtime
      Thread.current["mongomodel_runtime"] ||= 0
    end

    def self.reset_runtime
      rt, self.runtime = runtime, 0
      rt
    end

    def initialize
      super
      @odd_or_even = false
    end
    
    def query(event)
      self.class.runtime += event.duration
      return unless logger.debug?
      
      collection = '%s (%.1fms)' % [event.payload[:collection], event.duration]
      query      = event.payload[:query]
      
      if odd?
        collection = color(collection, CYAN, true)
        query      = color(query, nil, true)
      else
        collection = color(collection, MAGENTA, true)
      end
      
      debug "  #{collection}  #{query}"
    end
    
    def odd?
      @odd_or_even = !@odd_or_even
    end

    def logger
      MongoModel.logger
    end
  end
end

MongoModel::LogSubscriber.attach_to :mongomodel
