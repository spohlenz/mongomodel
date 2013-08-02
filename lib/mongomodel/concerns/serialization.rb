module MongoModel
  module Serialization
    extend ActiveSupport::Concern
    
    include ActiveModel::Serializers::JSON
    
    def serializable_hash(given_options = nil)
      options = given_options ? given_options.dup : {}

      options[:only]   = Array.wrap(options[:only]).map { |n| n.to_s }
      options[:except] = Array.wrap(options[:except]).map { |n| n.to_s }

      attribute_names = attributes_for_serialization.map { |a| a.to_s }
      
      if options[:only].any?
        attribute_names &= options[:only]
      elsif options[:except].any?
        attribute_names -= options[:except]
      end

      method_names = Array.wrap(options[:methods]).inject([]) do |methods, name|
        methods << name if respond_to?(name.to_s)
        methods
      end

      (attribute_names + method_names).inject({}) { |hash, name|
        hash[name] = send(name) if respond_to?(name)
        hash
      }
    end
  
  protected
    def attributes_for_serialization
      attributes.keys.reject { |attr|
        attr.to_s != "id" && self.class.properties[attr] && self.class.properties[attr].internal?
      }.sort
    end
  end
end
