module MongoModel
  class Reference < String
    def self.cast(value)
      value = value.to_s if value.respond_to?(:to_s)
      
      case value
      when "", nil
        nil
      else
        new(value)
      end
    end
  end
end
