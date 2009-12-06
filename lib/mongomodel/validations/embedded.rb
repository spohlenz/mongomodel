module MongoModel
  module Validations
    module ClassMethods
      def validates_embedded(*attr_names)
        configuration = attr_names.extract_options!

        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless (value.is_a?(Array) ? value : [value]).collect { |r| r.nil? || r.valid_without_callbacks? }.all?
            record.errors.add(attr_name, :invalid, :default => configuration[:message], :value => value)
          end
        end
      end
    end
  end
end
