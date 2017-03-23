module MongoModel
  class Reference
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def to_s
      id.to_s
    end

    alias :to_str :to_s

    def hash
      id.hash
    end

    def as_json(*)
      to_s
    end

    def blank?
      id.blank?
    end

    def eql?(other)
      case other
      when Reference
        id.to_s == other.id.to_s
      else
        id.to_s == other.to_s
      end
    end
    alias_method :==, :eql?

    def to_mongo
      id.blank? ? nil : id
    end

    def self.cast(value)
      case value
      when BSON::ObjectId
        new(value)
      else
        if BSON::ObjectId.legal?(value.to_s)
          new(BSON::ObjectId(value.to_s))
        else
          new(value.to_s)
        end
      end
    end

    def self.from_mongo(value)
      cast(value)
    end
  end
end
