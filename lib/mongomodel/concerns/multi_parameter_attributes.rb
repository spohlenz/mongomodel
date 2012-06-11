module MongoModel
  module MultiParameterAttributes
    extend ActiveSupport::Concern
    
    def attributes=(attrs)
      return if attrs.nil?
      attributes = {}
      multi_parameter_attributes = {}

      attrs.each do |key, value|
        if key =~ /^([^\(]+)\((\d+)([if])\)$/
          key, index = $1, $2.to_i
          (multi_parameter_attributes[key.to_sym] ||= [])[index-1] = value.empty? ? nil : value.send(:"to_#{$3}")
        else
          attributes[key] = value
        end
      end

      multi_parameter_attributes.each do |key, values|
        klass = self.class.properties[key].try(:type)
        attributes[key] = [DateTime, Date, Time].include?(klass) ? klass.new(*values) : values
      end

      super(attributes)
    end
    
  end
end
