module MongoModel
  module PrettyInspect
    extend ActiveSupport::Concern

    module ClassMethods
      # Returns a string like 'Post(title:String, body:String)'
      def inspect
        if [Document, EmbeddedDocument].include?(self)
          super
        else
          attr_list = model_properties.map { |name, property| "#{name}: #{property.type.inspect}" } * ', '
          "#{super}(#{attr_list})"
        end
      end
    end

    # Returns the contents of the document as a nicely formatted string.
    def inspect
      "#<#{self.class.name} #{attributes_for_inspect}>"
    end

  private
    def attributes_for_inspect
      attrs = self.class.model_properties.map { |name, property| "#{name}: #{send(name).inspect}" }
      attrs.unshift "id: #{id}" if self.class.properties.include?(:id)
      attrs * ', '
    end
  end
end
