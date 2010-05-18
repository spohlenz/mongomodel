module MongoModel
  module Serialization
    extend ActiveSupport::Concern
    
    include ActiveModel::Serializers::JSON
    
    def serializable_hash(given_options = nil)
      options = given_options ? given_options.dup : {}

      options[:only]   = Array.wrap(options[:only]).map { |n| n.to_s }
      options[:except] = Array.wrap(options[:except]).map { |n| n.to_s }

      attribute_names = attributes.keys.map { |k| k.to_s }.sort
      attribute_names -= self.class.internal_properties.map { |p| p.name.to_s }
      
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
  end
end
