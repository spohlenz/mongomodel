module MongoModel
  module Serialization
    extend ActiveSupport::Concern

    include ActiveModel::Serializers::JSON

    def serializable_hash(given_options = nil)
      options = given_options ? given_options.dup : {}

      options[:only]    = Array.wrap(options[:only]).map { |n| n.to_s }
      options[:except]  = Array.wrap(options[:except]).map { |n| n.to_s }
      options[:methods] = Array.wrap(options[:methods]).map { |n| n.to_s }

      attribute_names = attributes_for_serialization

      if options[:only].any?
        attribute_names &= options[:only]
      elsif options[:except].any?
        attribute_names -= options[:except]
      end

      method_names = options[:methods].inject([]) do |methods, name|
        methods << name if respond_to?(name)
        methods
      end

      (attribute_names + method_names).inject({}) { |hash, name|
        hash[name] = send(name) if respond_to?(name)
        hash
      }
    end

  protected
    def attributes_for_serialization
      properties.reject { |name, property|
        property.internal? && name != :id
      }.map { |name, property|
        name.to_s
      }.sort
    end
  end
end
